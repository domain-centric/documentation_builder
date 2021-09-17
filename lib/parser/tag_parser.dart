import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart' as analyzer;
import 'package:build/build.dart';
import 'package:documentation_builder/builder/documentation_builder.dart';
import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/element.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/attribute_parser.dart';
import 'package:documentation_builder/parser/link_parser.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'parser.dart';

/// The [TagParser] searches for [TextNode]'s that contain texts that represent a [Tag]
/// It then replaces these [TextNode]'s into a [Tag] and additional [TextNode]'s for the remaining text.
class TagParser extends Parser {
  TagParser()
      : super([
          ImportFileTagRule(),
          ImportCodeTagRule(),
          ImportDartCodeTagRule(),
          ImportDartDocTagRule(),
          TableOfContentsTagRule(),
        ]);
}

abstract class TagRule extends TextParserRule {
  final List<AttributeRule> attributeRules;

  TagRule(String name, this.attributeRules) : super(createExpression(name));

  static FluentRegex createExpression(String name) => FluentRegex()
      .literal('{')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(name)
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed(GroupName.attributes))
      .literal('}')
      .ignoreCase();

  @override
  Future<Node> createReplacementNode(
      ParentNode parent, RegExpMatch match) async {
    try {
      String attributesText = match.namedGroup(GroupName.attributes) ?? '';
      var tagAttributeParser = AttributeParser(attributeRules);
      Map<String, dynamic> attributes =
          await tagAttributeParser.parseToNameAndValues(attributesText);
      var tagNode = createTagNode(parent, attributes);
      var newChildren = await tagNode.createChildren();
      tagNode.children.addAll(newChildren);
      return tagNode;
    } on ParserWarning catch (warning) {
      // Wrap warning with tag information, so it can be found easily
      throw ParserWarning("$warning in tag: '${match.result}'.");
    }
  }

  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes);
}

/// [Tag]s are specific texts in [MarkdownTemplate]s that are replaced by the
///  [DocumentationBuilder] with other information
///  (e.g. by an imported Dart Documentation Comment) before the
///  [GeneratedMarkdownFile] is written.
///
/// [Tag]s:
/// - are surrounded by curly brackets: {}
/// - start with a name: e.g.  {ImportFile&rcub;
/// - may have [Attribute]s after the name:
///   e.g. {ImportFile path='OtherTemplateFile.mdt' title='## Other Template File'&rcub;
abstract class Tag extends ParentNode {
  final Map<String, dynamic> attributes;
  late final Anchor anchor;

  Tag(ParentNode? parent, this.attributes) : super(parent);

  Future<List<Node>> createChildren();
}

/// - **{ImportFile file:'OtherTemplateFile.mdt' title='## Other Template File'&rcub;**
/// - Imports another text file or markdown file.
/// - Attributes:
///   - path= (required) A [ProjectFilePath] to a file that needs to be imported.
///     This may be any type of text file (e.g. .mdt file).
///   - title= (optional) See [TitleAttribute]
class ImportFileTag extends Tag {
  ImportFileTag(ParentNode? parent, Map<String, dynamic> attributes)
      : super(parent, attributes);

  @override
  Future<List<Node>> createChildren() {
    ProjectFilePath path = attributes[AttributeName.path];
    String? title = attributes[AttributeName.title];
    var titleAndOrAnchor = TitleAndOrAnchor(this, title, path.toString());
    anchor = titleAndOrAnchor.anchor;
    var file = path.toFile();
    var fileText = (TextNode(this, _readFile(file)));
    return Future.value([titleAndOrAnchor, fileText]);
  }
}

/// Recognizes and creates an [ImportFileTag]
class ImportFileTagRule extends TagRule {
  ImportFileTagRule()
      : super('ImportFile', [
          ProjectFilePathAttribute(),
          TitleAttribute(),
        ]);

  @override
  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes) =>
      ImportFileTag(parent, attributes);
}

/// - **{ImportCodeTag file:'file_to_import.txt' title='## Code example'&rcub;**
/// - Imports a (none Dart) code file.
/// - Attributes:
///   - path= (required) A [ProjectFilePath] a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag] to import Dart code
///   - title= (optional) See [TitleAttribute]
class ImportCodeTag extends Tag {
  ImportCodeTag(ParentNode? parent, Map<String, dynamic> attributes)
      : super(parent, attributes);

  @override
  Future<List<Node>> createChildren() {
    ProjectFilePath path = attributes[AttributeName.path];
    String? title = attributes[AttributeName.title];
    var titleAndOrAnchor = TitleAndOrAnchor(this, title, path.toString());
    anchor = titleAndOrAnchor.anchor;
    var codePrefix = TextNode(this, "\n```\n");
    var file = path.toFile();
    var fileText = TextNode(this, _readCodeFile(file));
    var codeSuffix = TextNode(this, "\n```\n");
    return Future.value([
      titleAndOrAnchor,
      codePrefix,
      fileText,
      codeSuffix,
    ]);
  }
}

/// Recognizes and creates an [ImportCodeTag]
class ImportCodeTagRule extends TagRule {
  ImportCodeTagRule()
      : super('ImportCode', [
          ProjectFilePathAttribute(),
          TitleAttribute(),
        ]);

  @override
  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes) =>
      ImportCodeTag(parent, attributes);
}

/// - **{ImportDartCodeTag file:'file_to_import.dart' title='## Dart code example'&rcub;**
/// - Imports a (none Dart) code file.
/// - Attributes:
///   - path= (required) A [DartFilePath] to be imported as a Dart code example. See also [ImportCodeTag] to import none Dart code.
///   - title= (optional) See [TitleAttribute]
class ImportDartCodeTag extends Tag {
  ImportDartCodeTag(ParentNode? parent, Map<String, dynamic> attributes)
      : super(parent, attributes);

  @override
  Future<List<Node>> createChildren() async {
    DartFilePath path = attributes[AttributeName.path];
    String? title = attributes[AttributeName.title];
    var titleAndOrAnchor = TitleAndOrAnchor(this, title, path.toString());
    anchor = titleAndOrAnchor.anchor;
    var codePrefix = TextNode(this, "\n```dart\n");
    var code = _readCodeFile(path.toFile());
    var codeNode = TextNode(this, code);
    var codeSuffix = TextNode(this, "\n```\n");
    return [
      titleAndOrAnchor,
      codePrefix,
      codeNode,
      codeSuffix,
    ];
  }
}

/// Recognizes and creates an [ImportDartCodeTag]
class ImportDartCodeTagRule extends TagRule {
  ImportDartCodeTagRule()
      : super('ImportDartCode', [
          DartFilePathAttribute(),
          TitleAttribute(),
        ]);

  @override
  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes) =>
      ImportDartCodeTag(parent, attributes);
}

/// - **{ImportDartDoc path='lib\my_lib.dart|MyClass' title='## My Class'&rcub;**
/// - Imports Dart documentation comments from a library member of a dart file.
/// - Attributes:
///   - path= (required) A [DartCodePath] to be imported Dart comments.
///   - title= (optional) See [TitleAttribute]
class ImportDartDocTag extends Tag {
  ImportDartDocTag(ParentNode? parent, Map<String, dynamic> attributes)
      : super(parent, attributes);

  @override
  Future<List<Node>> createChildren() async {
    DartCodePath path = attributes[AttributeName.path];
    String? title = attributes[AttributeName.title];
    var titleAndOrAnchor = TitleAndOrAnchor(this, title, path.toString());
    anchor = titleAndOrAnchor.anchor;
    var documentation = await _readDocumentationComments(parent!, path);
    // var documentation = _removeLeadingTripleSlashes(documentationComments);
    var codeNode = TextNode(this, documentation);
    return [
      titleAndOrAnchor,
      codeNode,
    ];
  }

  Future<String> _readDocumentationComments(
      ParentNode parent, DartCodePath path) async {
    validate(path);

    analyzer.LibraryElement library =
        await parseLibrary(parent, path.dartFilePath);

    analyzer.Element foundElement = findAnalyzerElement(library, path);

    String docComments =
        _removeLeadingTripleSlashes(foundElement.documentationComment!);
    validateIfNotEmpty(docComments, path);

    return docComments;
  }

  static final leadingTripleSlashesExpression = FluentRegex()
      .startOfLine()
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal('///')
      .whiteSpace(Quantity.atMost(1));
  static final lineBreakExpression = FluentRegex().lineBreak();

  _removeLeadingTripleSlashes(String documentationComments) {
    var lines = documentationComments.split(lineBreakExpression);
    String doc = '';
    lines.forEach((line) {
      doc += leadingTripleSlashesExpression.removeFirst(line) + '\n';
    });
    return doc;
  }

  void validate(DartCodePath path) {
    validateIfDartFilePathExists(path);
    validateIfMemberPathExists(path);
  }

  void validateIfDartFilePathExists(DartCodePath path) {
    if (!path.dartFilePath.toFile().existsSync()) {
      throw ParserWarning(
          'The Dart file could not be found in path attribute value: $path');
    }
  }

  void validateIfMemberPathExists(DartCodePath path) {
    if (path.dartMemberPath == null) {
      throw ParserWarning('No DartMemberPath in path attribute value: $path');
    }
  }

  analyzer.Element findAnalyzerElement(
      analyzer.Element element, DartCodePath path) {
    var visitor = ElementFinder(path.dartMemberPath!);
    element.visitChildren(visitor);

    analyzer.Element? foundElement = visitor.foundElement;
    if (foundElement == null) {
      throw ParserWarning(
          'Dart member: ${path.dartMemberPath} not found in: ${path.dartFilePath}');
    }
    return foundElement;
  }

  void validateIfMemberFound(
      analyzer.Element? foundElement, DartCodePath path) {
    if (foundElement == null) {}
  }

  void validateIfNotEmpty(String docComments, DartCodePath path) {
    if (docComments.trim().isEmpty) {
      throw ParserWarning(
          'Dart member: ${path.dartMemberPath} has no Dart documentation comments in: ${path.dartFilePath}');
    }
  }
}

Future<analyzer.LibraryElement> parseLibrary(
    ParentNode parent, ProjectFilePath dartFile) async {
  try {
    var documentationModel = parent.findParent<DocumentationModel>();
    var resolver = documentationModel!.buildStep!.resolver;
    var assetId = AssetId(LocalProject.name, dartFile.path);
    var library = await resolver.libraryFor(assetId);
    return library;
  } on Exception catch (e) {
    throw ParserWarning('Could not parse library file: ${dartFile.path}',
        ParserWarning(e.toString()));
  }
}

/// Recognizes and creates an [ImportDartDocTag]
class ImportDartDocTagRule extends TagRule {
  ImportDartDocTagRule()
      : super('ImportDartDoc', [
          DartCodePathAttribute(),
          TitleAttribute(),
        ]);

  @override
  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes) =>
      ImportDartDocTag(parent, attributes);
}

/// - **{TableOfContents title='## Table of contents example'&rcub;**
/// - Creates a table of contents.
/// - Attributes:
///   - title= (optional) See [TitleAttribute]
class TableOfContentsTag extends Tag {
  TableOfContentsTag(ParentNode? parent, Map<String, dynamic> attributes)
      : super(parent, attributes);

  @override
  Future<List<Node>> createChildren() {
    String toc = "";
    DocumentationModel? model = parent!.findParent<DocumentationModel>();
    if (model != null) {
      var templates = model.findOrderedMarkdownTemplates();
      for (MarkdownTemplate template in templates) {
        if (template.factory is WikiFile && !isWikiHomePage(template)) {
          Link titleLink = Link(
              parent: parent,
              title: template.title,
              uri: template.destinationWebUri!);
          toc += "## $titleLink\n";
          List<Title> subTitles = template.findChildren<Title>();
          for (Title subTitle in subTitles) {
            var title = subTitle.titleWithoutHashes;
            var uri = subTitle.anchor.uriToAnchor;
            var level = subTitle.level; //1,2,3
            if (uri != null && level <= 3) {
              Link subTitleLink = Link(parent: parent, title: title, uri: uri);
              toc += "${'  ' * (level-1)}- $subTitleLink\n";
            }
          }
        }
      }
    }
    String? titleText = attributes[AttributeName.title];
    var tableOfContents=TextNode(this, toc);
    if (titleText!=null && titleText.trim().isNotEmpty) {
      var title=Title(this, titleText);
      anchor = title.anchor;
      return Future.value([title, tableOfContents]);
    } else {
      return Future.value([tableOfContents]);
    }
  }

  bool isWikiHomePage(MarkdownTemplate template) =>
      template.sourceFilePath.path.toLowerCase().contains('home.mdt');
}

/// Recognizes and creates an [TableOfContentsTag]
class TableOfContentsTagRule extends TagRule {
  TableOfContentsTagRule()
      : super('TableOfContents', [
          TitleAttribute(),
        ]);

  @override
  Tag createTagNode(ParentNode parent, Map<String, dynamic> attributes) =>
      TableOfContentsTag(parent, attributes);
}

class TitleAndOrAnchor extends ParentNode {
  late final Anchor anchor;

  TitleAndOrAnchor(ParentNode? parent, String? title, String path)
      : super(parent) {
    if (title != null) {
      var titleNode = Title(this, title);
      anchor = titleNode.anchor;
      children.add(titleNode);
    } else {
      anchor = Anchor(this, path);
      children.add(anchor);
    }
  }
}

/// Represents a markdown title with a custom Anchor id that can be navigated to using [anchor.uriToAnchor]
///
/// Output example:
/// <a id='paragraph-titile'></a>
/// ## Paragraph Title
class Title extends ParentNode {
  late final Anchor anchor;
  final String title;
  final String titleWithoutHashes;

  /// The title can have leading hashtags to indicate the title level, e.g.:
  /// # = Chapter (level=1)
  /// ## = Paragraph (level=2)
  /// ### = Sub paragraph (level=3)
  /// etc... up to 6 levels.
  final int level;

  /// The title can have leading hashtags to indicate the title level, e.g.:
  /// # = Chapter
  /// ## = Paragraph
  /// ### = Sub paragraph
  /// etc... up to 6 levels.
  Title(ParentNode parent, this.title)
      : titleWithoutHashes = createTitleWithoutHashes(title),
        level = createLevel(title),
        super(parent) {
    anchor = Anchor(this, title);
    children.add(anchor);
    children.add(TextNode(this, '\n$title\n'));
  }

  static final FluentRegex _leadingHashExpression = FluentRegex()
      .startOfLine()
      .group(FluentRegex().whiteSpace(Quantity.zeroOrMoreTimes()).literal('#'),
          quantity: Quantity.atMost(6))
      .whiteSpace(Quantity.zeroOrMoreTimes());

  static createLevel(String title) {
    String? leadingHashes = _leadingHashExpression.findFirst(title);
    if (leadingHashes == null) {
      return 7;
    } else {
      return FluentRegex().literal('#').allMatches(leadingHashes).length;
    }
  }

  static createTitleWithoutHashes(String title) {
    return _leadingHashExpression.removeFirst(title);
  }
}

/// Represents a HTML anchor point to which you can refer to with a [uriToAnchor]
/// https://stackoverflow.com/questions/5319754/cross-reference-named-anchor-in-markdown
class Anchor extends Node {
  late final String html;
  late final String name;
  late final Uri? uriToAnchor;
  static final firstHyphen = FluentRegex().startOfLine().literal('-');
  static final multipleHyphen = FluentRegex().literal('-', Quantity.atLeast(2));
  static final whiteSpace = FluentRegex().whiteSpace();
  static final otherThanLettersNumbersAndHyphens = FluentRegex().characterSet(
      CharacterSet.exclude().addLetters().addDigits().addLiterals('-'));

  Anchor(ParentNode? parent, String textToChangeToName) : super(parent) {
    name = createName(textToChangeToName);
    html = createHtml(name);
    uriToAnchor = createUriToAnchor(name);
  }

  static String createHtml(String name) => "<a id='$name'></a>";

  /// Converts a text to a name that can be referred to in a uri.
  static String createName(String textToChangeToName) => textToChangeToName
      .trim()
      .replaceAll(whiteSpace, '-')
      .replaceAll(otherThanLettersNumbersAndHyphens, '-')
      .replaceAll(multipleHyphen, '-')
      .replaceAll(firstHyphen, '')
      .toLowerCase();

  Uri? createUriToAnchor(String name) {
    if (parent == null) return null;
    MarkdownTemplate? markdownTemplate = parent!.findParent<MarkdownTemplate>();
    if (markdownTemplate == null) return null;
    Uri? uri = markdownTemplate.destinationWebUri;
    if (uri == null) return null;
    uri = uri.replace(fragment: name);
    return uri;
  }

  @override
  String toString() => html;
}

String _readFile(File file) {
  try {
    return file.readAsStringSync();
  } on Exception catch (e) {
    throw ParserWarning(
        'Could not read file: ${file.path}.', ParserWarning(e.toString()));
  }
}

final _leadingWhiteSpace =
    FluentRegex().startOfLine().whiteSpace(Quantity.oneOrMoreTimes());
final _trailingWhiteSpace =
    FluentRegex().whiteSpace(Quantity.oneOrMoreTimes()).endOfLine();

String _trimWhiteSpace(String text) {
  text = _leadingWhiteSpace.removeFirst(text);
  var matches = _trailingWhiteSpace.allMatches(text);
  if (matches.isNotEmpty) {
    var lastMatch = matches.last;
    var endPos = lastMatch.end;
    if (endPos == text.length) {
      text = text.substring(0, lastMatch.start);
    }
  }
  return text;
}

String _readCodeFile(File file) => _trimWhiteSpace(_readFile(file));
