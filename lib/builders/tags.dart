import 'package:collection/collection.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/builders/tag_builder.dart';
import 'package:documentation_builder/generic/markdown_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:fluent_regex/fluent_regex.dart';

const pathName = 'path';
const titleName = 'title';

/// [TagFactory]s are used to parse text to [Tag] object's.
/// There is a [TagFactory] implementation for each [Tag] implementation.
///
/// It:
/// - creates a [fluentRegex] to match text
/// - defines the [Tag][attributes]
/// - uses the [Tag][attributes] to get the verify and get the [Attribute] values
/// - and then creates the [Tag]
abstract class TagFactory<T extends Tag> {
  static FluentRegex _tagSuffixExpression =
      FluentRegex().literal('tag').endOfLine().ignoreCase();

  static FluentRegex _whiteSpaceExpression = FluentRegex()
      .startOfLine()
      .whiteSpace(Quantity.zeroOrOneTime())
      .endOfLine();

  final String name;

  final List<Attribute> attributes;

  final FluentRegex fluentRegex;

  TagFactory(this.attributes)
      : name = _nameFromType(T),
        fluentRegex = createFluentRegex(T);

  static String _nameFromType(Type t) {
    return t.runtimeType.toString().replaceAll(_tagSuffixExpression, '');
  }

  T createFromString(String tagString) {
    String unParsedAttributes =
        fluentRegex.findCapturedGroups(tagString)['attributes'] ?? '';
    Map<String, String> attributeNamesAndValues = {};
    attributes.forEach((attribute) {
      if (attribute.fluentRegex.hasMatch(unParsedAttributes)) {
        String? value = attribute.valueFor(unParsedAttributes);
        if (value == null) {
          print(
              'The ${attribute.name} attribute value is invalid for tag: $tagString');
        } else {
          attributeNamesAndValues[attribute.name] = value;
        }
        unParsedAttributes =
            attribute.fluentRegex.replaceAll(unParsedAttributes, '');
      } else if (attribute.required) {
        print(
            'Missing the required ${attribute.name} attribute for tag: $tagString');
      }
    });

    if (!_whiteSpaceExpression.hasMatch(unParsedAttributes)) {
      print(
          "Invalid attribute information: '$unParsedAttributes' for tag: Tag: '$tagString'");
    }
    return createFromAttributes(attributeNamesAndValues);
  }

  T createFromAttributes(Map<String, String> attributeNamesAndValues);

  static FluentRegex createFluentRegex(Type t) => FluentRegex()
      .literal('{')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(_nameFromType(t))
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed('attributes'))
      .literal('}')
      .ignoreCase();
}


/// A list of all available [TagFactory] implementations
class TagFactories extends DelegatingList<TagFactory> {
  static TagFactories _singleton = TagFactories._();

  factory TagFactories() => _singleton;

  TagFactories._()
      : super([
          ImportFileTagFactory(),
          ImportCodeTagFactory(),
          ImportDartCodeTagFactory(),
          ImportDartDocTagFactory(),
        ]);
}


/// [Tag]s can contain [Attribute]s. These contain information for the [Tag] to do its work.
class Attribute {
  final FluentRegex fluentRegex;

  final String name;
  final bool required;

  Attribute(this.name, {required this.required})
      : fluentRegex = createFluentRegex(name);

  static createFluentRegex(String name) {
    //TODO
  }

  String? valueFor(String textContainingAttributeNameAndValue) =>
      fluentRegex.findCapturedGroups(textContainingAttributeNameAndValue)[name];
}

/// [MarkdownPage]s can contain [PlainText] that represent a [Tag]
/// The [TagBuilder] replaces all these texts with [Tag] objects.
///
/// [Tag] objects use [Tag][Attribute] values to create [MarkdownNode] e.g. by importing some text. Dart code or Dart comments
///
/// [Tag]s in text form:
/// - are surrounded by curly brackets: {}
/// - start with a name: e.g.  {ImportFile}
/// - may have [Attribute]s after the name: e.g. {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
abstract class Tag extends MarkdownParent {
  Tag(Map<String, String> attributeNamesAndValues) {
    markdownNodes = createMarkdownNodes(attributeNamesAndValues);
  }

  List<MarkdownNode> createMarkdownNodes(
      Map<String, String> attributeNamesAndValues);
}

/// [ImportFileTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
/// - It imports another file.
/// - Attributes:
///   - path: (required) A [ProjectFilePath] to a file name inside the markdown directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportFileTag extends Tag {
  ImportFileTag(Map<String, String> attributeNamesAndValues)
      : super(attributeNamesAndValues);

  @override
  List<MarkdownNode> createMarkdownNodes(
      Map<String, String> attributeNamesAndValues) {
    // TODO: implement createMarkdownNodes
    throw UnimplementedError();
  }
}

/// Creates a [ImportFileTag] when the tag string matches
class ImportFileTagFactory extends TagFactory<ImportFileTag> {
  ImportFileTagFactory()
      : super([
          Attribute(pathName, required: true),
          Attribute(titleName, required: false)
        ]);

  @override
  ImportFileTag createFromAttributes(
          Map<String, String> attributeNamesAndValues) =>
      ImportFileTag(attributeNamesAndValues);
}

/// [ImportCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportCodeTag file:'file_to_import.txt' title:'## Code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - path: (required) A [ProjectFilePath] a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag] to import Dart code
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportCodeTag extends Tag {
  ImportCodeTag(Map<String, String> attributeNamesAndValues)
      : super(attributeNamesAndValues);

  @override
  List<MarkdownNode> createMarkdownNodes(
      Map<String, String> attributeNamesAndValues) {
    // TODO: implement createMarkdownNodes
    throw UnimplementedError();
  }
}

/// Creates a [ImportCodeTag] when the tag string matches
class ImportCodeTagFactory extends TagFactory<ImportCodeTag> {
  ImportCodeTagFactory()
      : super([
          Attribute(pathName, required: true),
          Attribute(titleName, required: false)
        ]);

  @override
  ImportCodeTag createFromAttributes(
          Map<String, String> attributeNamesAndValues) =>
      ImportCodeTag(attributeNamesAndValues);
}

/// [ImportDartCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartCodeTag file:'file_to_import.dart' title:'## Dart code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - path: (required) A [DartCodePath] to be imported as a Dart code example. See also [ImportCodeTag] to import none Dart code.
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartCodeTag extends Tag {
  ImportDartCodeTag(Map<String, String> attributeNamesAndValues)
      : super(attributeNamesAndValues);

  @override
  List<MarkdownNode> createMarkdownNodes(
      Map<String, String> attributeNamesAndValues) {
    // TODO: implement createMarkdownNodes
    throw UnimplementedError();
  }
}

/// Creates a [ImportDartCodeTag] when the tag string matches
class ImportDartCodeTagFactory extends TagFactory<ImportDartCodeTag> {
  ImportDartCodeTagFactory()
      : super([
          Attribute(pathName, required: true),
          Attribute(titleName, required: false)
        ]);

  @override
  ImportDartCodeTag createFromAttributes(
          Map<String, String> attributeNamesAndValues) =>
      ImportDartCodeTag(attributeNamesAndValues);
}

/// [ImportDartDocTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartDoc member:'lib\my_lib.dart.MyClass' title:'## My Class'}
/// - It imports dart documentation comments from dart files.
/// - Attributes:
///   - path: (required) A [DartCodePath] to be imported Dart comments.
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartDocTag extends Tag {
  ImportDartDocTag(Map<String, String> attributeNamesAndValues)
      : super(attributeNamesAndValues);

  @override
  List<MarkdownNode> createMarkdownNodes(
      Map<String, String> attributeNamesAndValues) {
    // TODO: implement createMarkdownNodes
    throw UnimplementedError();
  }
}

/// Creates a [ImportDartDocTag] when the tag string matches
class ImportDartDocTagFactory extends TagFactory<ImportDartDocTag> {
  ImportDartDocTagFactory()
      : super([
          Attribute(pathName, required: true),
          Attribute(titleName, required: false)
        ]);

  @override
  ImportDartDocTag createFromAttributes(
          Map<String, String> attributeNamesAndValues) =>
      ImportDartDocTag(attributeNamesAndValues);
}

/// TODO - generate a table of contents e.g. {tableOfContents <x levels deep>}}
/// TODO - generate a change log e.g. {ChangeLog <git details>}
