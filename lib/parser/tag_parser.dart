import 'dart:io';

import 'package:documentation_builder/builders/template_builder.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
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
          type: GroupType.captureUnNamed())
      .literal('}')
      .ignoreCase();

  @override
  Node createReplacementNode(ParentNode parent, String tagText) {
    try {
      String attributesText = expression
              .findCapturedGroups(tagText)
              .values
              .firstWhere((value) => value != null) ??
          '';
      var tagAttributeParser = TagAttributeParser(attributeRules);
      Map<String, dynamic> attributeNamesAndValues =
          tagAttributeParser.parseToNameAndValues(attributesText);
      return createTagNode(parent, attributeNamesAndValues);
    } on ParserWarning catch (warning) {
      // Wrap warning with tag information, so it can be found easily
      throw ParserWarning("$warning in tag: '$tagText'.");
    }
  }

  Tag createTagNode(
      ParentNode parent, Map<String, dynamic> attributeNamesAndValues);
}

/// [Tag] objects use [Tag] [Attribute] values to create it's children e.g. by importing some text. Dart code or Dart comments
///
/// [Tag]s in text form:
/// - are surrounded by curly brackets: {}
/// - start with a name: e.g.  {ImportFile}
/// - may have [Attribute]s after the name: e.g. {ImportFile path:'OtherTemplateFile.mdt' title:'## Other Template File'}
abstract class Tag extends ParentNode {
  final Map<String, dynamic> attributeNamesAndValues;
  late final Anchor anchor;

  Tag(ParentNode? parent, this.attributeNamesAndValues) : super(parent);
}

/// [ImportFileTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
/// - It imports another file.
/// - Attributes:
///   - path: (required) A [ProjectFilePath] to a file name inside the markdown directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportFileTag extends Tag {
  ImportFileTag(
      ParentNode? parent, Map<String, dynamic> attributeNamesAndValues)
      : super(parent, attributeNamesAndValues) {
    ProjectFilePath path = attributeNamesAndValues['path'];
    String? title = attributeNamesAndValues['title'];
    var titleAndOrAnchor = TitleAndOrAnchor(this, title, path.toString());
    anchor = titleAndOrAnchor.anchor;
    var fileText = (TextNode(this, _readFile(path)));
    children.addAll([titleAndOrAnchor, fileText]);
  }

  String _readFile(ProjectFilePath path) {
    try {
      File file = path.toFile();
      return file.readAsStringSync();
    } on Exception catch (e) {
      throw ParserWarning(
          'Could not read file: $path.', ParserWarning(e.toString()));
    }
  }
}

/// Recognizes and creates an [ImportFileTag]
class ImportFileTagRule extends TagRule {
  ImportFileTagRule()
      : super('ImportFile', [
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);

  @override
  Tag createTagNode(
          ParentNode parent, Map<String, dynamic> attributeNamesAndValues) =>
      ImportFileTag(parent, attributeNamesAndValues);
}

/// [ImportCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportCodeTag file:'file_to_import.txt' title:'## Code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - path: (required) A [ProjectFilePath] a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag] to import Dart code
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportCodeTag extends Tag {
  ImportCodeTag(
      ParentNode? parent, Map<String, dynamic> attributeNamesAndValues)
      : super(parent, attributeNamesAndValues) {
    //TODO create children
  }
}

/// Recognizes and creates an [ImportCodeTag]
class ImportCodeTagRule extends TagRule {
  ImportCodeTagRule()
      : super('ImportCode', [
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);

  @override
  Tag createTagNode(
          ParentNode parent, Map<String, dynamic> attributeNamesAndValues) =>
      ImportCodeTag(parent, attributeNamesAndValues);
}

/// [ImportDartCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartCodeTag file:'file_to_import.dart' title:'## Dart code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - path: (required) A [DartCodePath] to be imported as a Dart code example. See also [ImportCodeTag] to import none Dart code.
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartCodeTag extends Tag {
  ImportDartCodeTag(
      ParentNode? parent, Map<String, dynamic> attributeNamesAndValues)
      : super(parent, attributeNamesAndValues) {
    //TODO create children
  }
}

/// Recognizes and creates an [ImportDartCodeTag]
class ImportDartCodeTagRule extends TagRule {
  ImportDartCodeTagRule()
      : super('ImportDartCode', [
          DartCodePathAttributeRule(),
          TitleAttributeRule(),
        ]);

  @override
  Tag createTagNode(
          ParentNode parent, Map<String, dynamic> attributeNamesAndValues) =>
      ImportDartCodeTag(parent, attributeNamesAndValues);
}

/// [ImportDartDocTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartDoc member:'lib\my_lib.dart.MyClass' title:'## My Class'}
/// - It imports dart documentation comments from dart files.
/// - Attributes:
///   - path: (required) A [DartCodePath] to be imported Dart comments.
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartDocTag extends Tag {
  ImportDartDocTag(
      ParentNode? parent, Map<String, dynamic> attributeNamesAndValues)
      : super(parent, attributeNamesAndValues) {
    //TODO create children
  }
}

/// Recognizes and creates an [ImportDartDocTag]
class ImportDartDocTagRule extends TagRule {
  ImportDartDocTagRule()
      : super('ImportDartDoc', [
          DartCodePathAttributeRule(),
          TitleAttributeRule(),
        ]);

  @override
  Tag createTagNode(
          ParentNode parent, Map<String, dynamic> attributeNamesAndValues) =>
      ImportDartDocTag(parent, attributeNamesAndValues);
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

class Title extends ParentNode {
  late final Anchor anchor;
  static final dashPrefixExpression = FluentRegex()
      .startOfLine()
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .group(FluentRegex().literal('#', Quantity.between(0, 6)),
          type: GroupType.captureUnNamed());

  Title(ParentNode parent, String title) : super(parent) {
    anchor = Anchor(this, title);
    children.add(anchor);
    children.add(TextNode(this, '\n$title\n'));
  }

  /// Gets the dashes before the title.
  /// This is an indication for the level, e.g.:
  /// # = Chapter
  /// ## = Paragraph
  /// ### = Sub paragraph
  /// etc...
  ///
  /// The title gets 6 dashes (lowest level in MarkDown) if no dashes where specified.
  static String dashesBeforeTitle(String title) {
    String dashesBeforeTitle =
        dashPrefixExpression.findCapturedGroups(title).values.first!;
    if (dashesBeforeTitle.isEmpty) dashesBeforeTitle = '######';
    return dashesBeforeTitle;
  }

  /// Gets the title without the title prefix
  static String titleWithoutDashes(String title) =>
      dashPrefixExpression.removeFirst(title);
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
  static final otherThanLettersNumbersAndHyphens = FluentRegex()
      .characterSet(CharacterSet.exclude().addLetters().addDigits().addLiterals('-'));

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
      .replaceAll(otherThanLettersNumbersAndHyphens, '')
      .replaceAll(multipleHyphen, '-')
      .replaceAll(firstHyphen, '')
      .toLowerCase();

  Uri? createUriToAnchor(String name) {
    if (parent == null) return null;
    MarkdownTemplate? markdownTemplate = parent!.findParent<MarkdownTemplate>();
    if (markdownTemplate == null) return null;
    Uri? uri = markdownTemplate.destinationWebUri;
    if (uri == null) return null;
    uri=uri.withPathSuffix('#$name');
    return uri;
  }

  @override
  String toString() => html;
}
