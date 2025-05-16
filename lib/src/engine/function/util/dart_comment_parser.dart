// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/function/util/reference.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:petitparser/petitparser.dart';
import 'package:template_engine/template_engine.dart';

/// [DartDocCommentParser] parses dart documentation comments:
/// * It removes leading comment headers: <whitespace>///<space>
/// * It will validate links with a uri, e.g. [Google](https://google.com)
/// * It tries to resolve links without a uri to links with a uri, e.g. [my_package] or [MyClass] or [MyClass.member]
///
class DartDocCommentParser {
  final Parser _parser;

  DartDocCommentParser() : _parser = _buildParser();

  static Parser _buildParser() {
    final openBracket = char('[');
    final closeBracket = char(']');
    final openParen = char('(');
    final closeParen = char(')');
    final text = pattern('^]').plus().flatten();
    final link = pattern('^)').plus().flatten();

    final Parser<RenderFunction> linkWithUrl =
        (openBracket & text & closeBracket & openParen & link & closeParen).map(
            ((values) =>
                ValidateLink(linkText: values[1], linkUrl: values[4])));
    final Parser<RenderFunction> linkWithoutUrl =
        (openBracket & text & closeBracket)
            .map((values) => ReferenceConverter(values[1]));
    final Parser<String> commentPrefix =
        (pattern(' \t').star() & string('///') & char(' ').repeat(0, 1))
            .map(replaceWithNothing);

    final Parser<String> otherCharacter =
        ((commentPrefix | linkWithUrl | linkWithoutUrl).not() & any())
            .map((values) => values[1]);

    return ((commentPrefix | linkWithUrl | linkWithoutUrl | otherCharacter)
            .star())
        .end();
  }

  static String replaceWithNothing(List values) => '';

  Result<dynamic> parse(String input) => _parser.parse(input);

  Future<Result<String>> parseAndRender(
    RenderContext renderContext,
    Element element,
    dartDocComments,
  ) async {
    var parseResult = _parser.parse(dartDocComments);
    if (parseResult is Failure) {
      return parseResult;
    }
    try {
      var renderResult = await render(renderContext, element, parseResult);
      return Success(dartDocComments, dartDocComments.length, renderResult);
    } on Exception catch (e) {
      return Failure(dartDocComments, dartDocComments.length,
          'Render exception: ${e.toString()}');
    }
  }

  Future<String> render(RenderContext renderContext, Element element,
      Result<dynamic> parseResult) async {
    var renderResult = <String>[];
    if (parseResult.value is Iterable) {
      for (var item in parseResult.value) {
        if (item is RenderFunction) {
          renderResult.add(await item.render(renderContext, element));
        } else {
          renderResult.add(item);
        }
      }
    } else {
      renderResult.add(parseResult.value);
    }
    return renderResult.join();
  }
}

abstract class RenderFunction {
  Future<String> render(RenderContext renderContext, Element element);
}

/// Dart Documentation Comments can contain references.
/// See https://dart.dev/tools/doc-comments/references
/// We try to replace them with a markdown link
///
/// [reference] can be:
/// * a named element related to the [docCommentsOwner]
/// * a named element related to the [docCommentsOwner.library]
/// * a [DartType]
class ReferenceConverter extends RenderFunction {
  String linkText;
  ReferenceConverter(String linkText) : this.linkText = linkText.trim();

  @override
  Future<String> render(RenderContext renderContext, Element element) async {
    try {
      Uri packageUri = (await PubDevProject.createForProject(linkText)).uri;
      return MarkDownLink(linkText, packageUri).toString();
    } catch (e) {
      // failed, try to get a code reference
    }

    Uri? libraryUri =
        await createLibraryReferenceUri(renderContext, element, linkText);
    if (libraryUri != null) {
      return MarkDownLink(linkText, libraryUri).toString();
    }

    /// not recognized so return as is.
    return Future.value('[$linkText]');
  }

  /// Dart Documentation Comments can contain references.
  /// See https://dart.dev/tools/doc-comments/references
  /// We try to resolve them to a [Uri].
  Future<Uri?> createLibraryReferenceUri(
    RenderContext renderContext,
    Element docCommentsOwner,
    String reference,
  ) async {
    try {
      final library = docCommentsOwner.library;
      final sourceUri = library?.source.uri;
      if (sourceUri == null) {
        return null;
      }
      var path = ProjectFilePath2(sourceUri.pathSegments.skip(1).join('/'));

      var gitHubProject = GitHubProject.of(renderContext);

      String? commitSHA = gitHubProject.getLatestCommitSHA();
      if (commitSHA == null) {
        return gitHubProject.sourceFileUri(path);
      }

      int? lineNr = getLineNr(docCommentsOwner, linkText);
      if (lineNr == null) {
        return gitHubProject.sourceFileUri(path);
      }

      //e.g.: https://github.com/domain-centric/documentation_builder/blob/9e5bd3f6eb6da1dc107faa2fe3a2d19b7c043a8d/lib/src/builder/documentation_builder.dart#L24
      return gitHubProject.sourceFileUri(path,
          tagName: commitSHA, lineNr: lineNr);
    } catch (e) {}
    return null;
  }

  String? createPath(Uri sourceUri) {
    var sourcePath = sourceUri.pathSegments.skip(1).join('/');
    var potentialParentFolders = <String>[
      'lib/',
      '',
      'bin/',
      'web/',
      'example/'
    ];
    for (var potentialParentFolder in potentialParentFolders) {
      var potentialPath = '$potentialParentFolder$sourcePath';
      if (File(potentialPath).existsSync()) {
        return potentialPath;
      }
    }
    log.warning('Could not find: $sourcePath');
    return null;
  }

  String? getParameterFromYaml(String yaml, String parameterName) {
    var start = yaml.indexOf(', $parameterName:');
    var end = yaml.indexOf(',', start + 1);
    if (start == -1 || end == -1) {
      return null;
    }
    return yaml.substring(start + parameterName.length + 4, end);
  }

  int? getLineNr(Element docCommentsOwner, String reference) {
    final session = docCommentsOwner.session;
    if (session == null) {
      return null;
    }
    var library = docCommentsOwner.library;
    if (library == null) {
      return null;
    }
    final parsedLibrary =
        session.getParsedLibraryByElement(library) as ParsedLibraryResult;
    final declaration = parsedLibrary.getElementDeclaration(docCommentsOwner);
    if (declaration == null) {
      return null;
    }
    final node = declaration.node;
    final elementOffset = node.offset;
    var compilationUnit = declaration.node.root as CompilationUnit;
    var lineInfo = compilationUnit.lineInfo;

    var source = library.source.contents.data;
    var referenceOffset = source.indexOf('[$reference]', elementOffset);
    if (referenceOffset == -1) {
      return lineInfo.getLocation(elementOffset).lineNumber;
    } else {
      return lineInfo.getLocation(referenceOffset).lineNumber;
    }
  }
}

class ValidateLink extends RenderFunction {
  final String linkText;
  final String linkUrl;

  ValidateLink({required this.linkText, required this.linkUrl});

  @override
  Future<String> render(RenderContext renderContext, Element element) async {
    await validateUrl();
    return Future.value('[$linkText]($linkUrl)');
  }

  Future validateUrl() async {
    try {
      final uri = Uri.parse(linkUrl);

      if (!uri.hasScheme || !uri.hasAuthority) {
        log.warning('Invalid URL: $linkUrl');
      }
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        if (!await uri.canGetWithHttp()) {
          log.warning('URL did not return a successful response: $linkUrl');
        }
      }
    } catch (e) {
      log.warning('Invalid URL: $linkUrl, Error: $e');
    }
  }
}
