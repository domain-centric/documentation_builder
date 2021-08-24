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
abstract class Tag extends Node {
  Tag(ParentNode? parent) : super(parent);
}

/// [ImportFileTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
/// - It imports another file.
/// - Attributes:
///   - path: (required) A [ProjectFilePath] to a file name inside the markdown directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportFileTag extends Tag {
  ImportFileTag(
      ParentNode? parent, Map<String, dynamic> attributeNamesAndValues)
      : super(parent) {
    //TODO create children
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
      : super(parent) {
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
      : super(parent) {
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
      : super(parent) {
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
