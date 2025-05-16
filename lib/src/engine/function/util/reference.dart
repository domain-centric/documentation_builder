// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/src/engine/function/util/analyzer.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:template_engine/template_engine.dart';

class MarkDownLink {
  final String text;
  final Uri uri;

  MarkDownLink(this.text, this.uri);

  @override
  String toString() => '[$text]($uri)';
}

abstract class MarkDownLinkFactory {
  Future<MarkDownLink?> create({
    required RenderContext context,
    required String reference,
    String? text,
  });
}

class MarkDownLinkFactories extends UnmodifiableListView<MarkDownLinkFactory>
    implements MarkDownLinkFactory {
  MarkDownLinkFactories()
      : super([
          UrlMarkDownLinkFactory(),
          PubDevPackageLinkFactory(),
          SourceLinkFactory(),
        ]);

  @override
  Future<MarkDownLink?> create({
    required RenderContext context,
    required String reference,
    String? text,
  }) async {
    for (var factory in this) {
      var markdownLink = await factory.create(
          context: context, reference: reference, text: text);
      if (markdownLink != null) {
        return markdownLink;
      }
    }
    return null;
  }
}

class UrlMarkDownLinkFactory implements MarkDownLinkFactory {
  @override
  Future<MarkDownLink?> create({
    required RenderContext context,
    required String reference,
    String? text,
  }) async {
    try {
      var uri = Uri.parse(reference);
      if (await uri.canGetWithHttp()) {
        return MarkDownLink(text ?? createText(uri), uri);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String createText(Uri uri) =>
      uri.path.isEmpty ? uri.host : uri.pathSegments.last;
}

class PubDevPackageLinkFactory implements MarkDownLinkFactory {
  @override
  Future<MarkDownLink?> create({
    required RenderContext context,
    required String reference,
    String? text,
  }) async {
    try {
      var pubDevProject = (await PubDevProject.createForProject(reference));
      return MarkDownLink(text ?? reference, pubDevProject.uri);
    } catch (e) {
      return null;
    }
  }
}

class SourceLinkFactory implements MarkDownLinkFactory {
  @override
  @override
  Future<MarkDownLink?> create({
    required RenderContext context,
    required String reference,
    String? text,
  }) async {
    var path = SourcePath(reference);

    var dartLibraryMemberPath = path.dartLibraryMemberPath;
    if (dartLibraryMemberPath == null) {
      var uri = GitHubProject.of(context).sourceFileUri(path.projectFilePath);
      if (await uri.canGetWithHttp()) {
        return MarkDownLink(text ?? uri.toString(), uri);
      }
      return null;
    }

    var library = await resolveLibrary(context, path.projectFilePath);

    var foundElement = findElementRecursively(library, dartLibraryMemberPath);
    validateIfMemberFound(foundElement, path);

    Uri? uri = await createDartReferenceUri(context, foundElement!);
    if (uri != null && await uri.canGetWithHttp()) {
      return MarkDownLink(text ?? reference, uri);
    }

    return null;
  }

  Future<String> createLink(String linkText, Uri linkUri) =>
      Future.value('[$linkText]($linkUri)');

  Future<Uri?> createDartReferenceUri(
      RenderContext renderContext, Element element) async {
    try {
      final library = element.library;
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

      int? lineNr = getLineNr(element);
      if (lineNr == null) {
        return gitHubProject.sourceFileUri(path);
      }

      //e.g.: https://github.com/domain-centric/documentation_builder/blob/9e5bd3f6eb6da1dc107faa2fe3a2d19b7c043a8d/lib/src/builder/documentation_builder.dart#L24
      return gitHubProject.uri
          .append(path: 'blob/$commitSHA/$path', fragment: 'L$lineNr');
    } catch (e) {}
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

  int? getLineNr(Element docCommentsOwner) {
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

    return lineInfo.getLocation(elementOffset).lineNumber;
  }
}
