import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/link_parser.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'parser.dart';

class AttributeParser extends Parser {
  AttributeParser(List<AttributeRule> rules) : super(rules);

  /// attributes are the inside of a [Tag] string
  Future<Map<String, dynamic>> parseToNameAndValues(String attributes) async {
    var rootNode = createRootNode(attributes);
    await parse(rootNode);
    validateIfAllTextNodesOnlyContainWhiteSpace(rootNode);
    validateIfAllRequiredAttributesAreFound(rootNode);
    return createNameAndValueMap(rootNode);
  }

  Map<String, dynamic> createNameAndValueMap(RootNode rootNode) {
    Map<String, dynamic> nameAndValues = {};
    for (Node child in rootNode.children) {
      if (child is Attribute) nameAndValues[child.name] = child.value;
    }
    return nameAndValues;
  }

  RootNode createRootNode(String text) {
    RootNode rootNode = RootNode();
    rootNode.children.add(TextNode(rootNode, text));
    return rootNode;
  }

  void validateIfAllTextNodesOnlyContainWhiteSpace(RootNode rootNode) {
    for (Node child in rootNode.children) {
      if (child is TextNode && child.text.trim().isNotEmpty)
        throw ParserWarning(
            "'${child.text.trim()}' could not be parsed to an attribute");
    }
  }

  void validateIfAllRequiredAttributesAreFound(RootNode rootNode) {
    rules.forEach((rule) {
      if ((rule as AttributeRule).required) {
        String name = rule.name;
        var missing = rootNode.children
            .where((node) => (node is Attribute) && node.name == name)
            .isEmpty;
        if (missing) throw ParserWarning('Required $name attribute is missing');
      }
    });
  }
}

abstract class AttributeRule extends TextParserRule {
  final String name;
  final bool required;

  AttributeRule(this.name, {required this.required})
      : super(createExpression(name));

  static final valueExpression =
      FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant);

  static createExpression(String name) => FluentRegex()
      .whiteSpace(Quantity.oneOrMoreTimes())
      .literal(name)
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .characterSet(CharacterSet().addLiterals(':='))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .characterSet(CharacterSet().addLiterals('"\''))
      .group(valueExpression, type: GroupType.captureNamed(GroupName.value))
      .characterSet(CharacterSet().addLiterals('"\''));

  String stringValueFor(RegExpMatch match) {
    String? value = match.namedGroup(GroupName.value);
    if (value == null)
      throw Exception(
          "Could not find value for $name attribute in: '${match.result}'");
    return value;
  }
}

/// [Tag]s can contain [Attribute]s. These contain additional information for the [Tag].
/// [Attribute]s can be mandatory or optional.
class Attribute<T> extends Node {
  final String name;
  final T value;

  Attribute({
    required ParentNode parent,
    required this.name,
    required this.value,
  }) : super(parent);
}
class ProjectFilePathAttribute extends Attribute<ProjectFilePath> {
  ProjectFilePathAttribute({
    required ParentNode parent,
    required String name,
    required String projectFilePath,
  }) : super(
    parent: parent,
    name: name,
    value: ProjectFilePath(projectFilePath),
  );

}

class ProjectFilePathAttributeRule extends AttributeRule {
  ProjectFilePathAttributeRule(
      {String name = AttributeName.path, bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(ProjectFilePathAttribute(
        parent: parent,
        name: name,
        projectFilePath: stringValueFor(match),
      ));
  }
}

class UriSuffixAttribute extends Attribute<UriSuffixPath> {
  UriSuffixAttribute({
    required ParentNode parent,
    required String name,
    required String uriSuffix,
  }) : super(
    parent: parent,
    name: name,
    value: UriSuffixPath(uriSuffix),
  );
}

class UriSuffixAttributeRule extends AttributeRule {
  UriSuffixAttributeRule({String name = AttributeName.suffix, bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(UriSuffixAttribute(
        parent: parent,
        name: name,
        uriSuffix: stringValueFor(match),
      ));
  }
}

class DartFilePathAttribute extends Attribute<DartFilePath> {
  DartFilePathAttribute({
    required ParentNode parent,
    required String name,
    required String dartFilePath,
  }) : super(
    parent: parent,
    name: name,
    value: DartFilePath(dartFilePath),
  );
}

class DartFilePathAttributeRule extends AttributeRule {
  DartFilePathAttributeRule(
      {String name = AttributeName.path, bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(DartFilePathAttribute(
        parent: parent,
        name: name,
        dartFilePath: stringValueFor(match),
      ));
  }
}

class DartCodePathAttribute extends Attribute<DartCodePath> {
  DartCodePathAttribute({
    required ParentNode parent,
    required String name,
    required String dartCodePath,
  }) : super(
    parent: parent,
    name: name,
    value: DartCodePath(dartCodePath),
  );
}

class DartCodePathAttributeRule extends AttributeRule {
  DartCodePathAttributeRule(
      {String name = AttributeName.path, bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(DartCodePathAttribute(
        parent: parent,
        name: name,
        dartCodePath: stringValueFor(match),
      ));
  }
}

class StringAttributeRule extends AttributeRule {
  StringAttributeRule(String name, {bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(Attribute<String>(
        parent: parent,
        name: name,
        value: stringValueFor(match),
      ));
  }
}

/// You can specify a title with a [TitleAttribute].
/// [TitleAttribute]s are often optional.
///
/// You can precede the title with a number of hashes #: to indicate the title level, e.g.:
/// - #=chapter
/// - ##=paragraph
/// - ###=sub paragraph
///
/// [TitleAttribute] example: title='## My Title'
///
/// A [TitleAttribute]s can be referenced in the documentation, e.g. with a [MarkdownFileLink] or [DartCodeLink]
class TitleAttribute extends Attribute<String> {
  TitleAttribute({
    required ParentNode parent,
    required String name,
    required String value,
  }) : super(
          parent: parent,
          name: name,
          value: value,
        ) {
    validate(value);
  }

  validate(String text) {
    if (text.trim().isEmpty) {
      throw Exception('Title may not be empty');
    }
  }
}

class TitleAttributeRule extends StringAttributeRule {
  TitleAttributeRule({String name = AttributeName.title, bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      return Future.value(TitleAttribute(
        parent: parent,
        name: name,
        value: stringValueFor(match),
      ));
  }
}
