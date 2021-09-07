import 'package:documentation_builder/generic/paths.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'parser.dart';

class TagAttributeParser extends Parser {
  TagAttributeParser(List<AttributeRule> rules) : super(rules);

  /// attributeNamesAndValues are the inside of a [Tag] string
  Future<Map<String, dynamic>> parseToNameAndValues(
      String attributeNamesAndValues) async {
    var rootNode = createRootNode(attributeNamesAndValues);
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

  static String groupNameValue='value';

  static createExpression(String name) => FluentRegex()
      .whiteSpace(Quantity.oneOrMoreTimes())
      .literal(name)
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .characterSet(CharacterSet().addLiterals(':='))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .characterSet(CharacterSet().addLiterals('"\''))
      .group(valueExpression, type: GroupType.captureNamed(groupNameValue))
      .characterSet(CharacterSet().addLiterals('"\''));

  String stringValueFor(RegExpMatch match) {
    String? value = match.namedGroup(groupNameValue);
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

class ProjectFilePathAttributeRule extends AttributeRule {
  ProjectFilePathAttributeRule({String name = 'path', bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
      try {
        return Future.value(Attribute<ProjectFilePath>(
          parent: parent,
          name: name,
          value: ProjectFilePath(stringValueFor(match)),
        ));
      } on Exception catch (e) {
        _throwParserWarning(e);
      }

  }



}

class UriSuffixAttributeRule extends AttributeRule {
  UriSuffixAttributeRule({String name = 'suffix', bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent,  RegExpMatch match) {
    try {
      return Future.value(Attribute<UriSuffixPath>(
        parent: parent,
        name: name,
        value: UriSuffixPath(stringValueFor(match)),
      ));
    } on Exception catch (e) {
      _throwParserWarning(e);
    }
  }
}

class DartFilePathAttributeRule extends AttributeRule {
  DartFilePathAttributeRule({String name = 'path', bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent,  RegExpMatch match) {
    try {
      return Future.value(Attribute<ProjectFilePath>(
        parent: parent,
        name: name,
        value: DartFilePath(stringValueFor(match)),
      ));
    } on Exception catch (e) {
      _throwParserWarning(e);
    }
  }
}

Never _throwParserWarning(Exception e) =>
    throw ParserWarning(e.toString().replaceAll('Exception: ', ''));

class DartCodePathAttributeRule extends AttributeRule {
  DartCodePathAttributeRule({String name = 'path', bool required = true})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    try {
      return Future.value(Attribute<DartCodePath>(
        parent: parent,
        name: name,
        value: DartCodePath(stringValueFor(match)),
      ));
    } on Exception catch (e) {
      _throwParserWarning(e);
    }
  }
}

class StringAttributeRule extends AttributeRule {
  StringAttributeRule(String name, {bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent,  RegExpMatch match) {
    try {
      return Future.value(Attribute<String>(
        parent: parent,
        name: name,
        value: stringValueFor(match),
      ));
    } on Exception catch (e) {
      _throwParserWarning(e);
    }
  }
}

class TitleAttributeRule extends StringAttributeRule {
  TitleAttributeRule({String name = 'title', bool required = false})
      : super(name, required: required);

  @override
  Future<Node> createReplacementNode(ParentNode parent,  RegExpMatch match) {
    try {
      return Future.value(Attribute<String>(
        parent: parent,
        name: name,
        value: validate(stringValueFor(match)),
      ));
    } on Exception catch (e) {
      _throwParserWarning(e);
    }
  }

  String validate(String text) {
    if (text.trim().isEmpty) throw Exception('Title may not be empty');
    return text;
  }
}


