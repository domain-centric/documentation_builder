import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/attribute_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// The [BadgeParser] searches for [TextNode]'s that contain texts that represent a [Badge]
/// It then replaces these [TextNode]'s into a [Badge] and additional [TextNode]'s for the remaining text.
class BadgeParser extends Parser {
  BadgeParser()
      : super([
          CustomBadgeRule(),
        ]);
}

/// A [Badge] can have a [ToolTipAttribute].
/// This text becomes visible when hoovering over a [Badge]
///
/// [ToolTipAttribute] example: tooltip='MIT License'
class ToolTipAttribute extends Attribute<String> {
  ToolTipAttribute({
    required ParentNode parent,
    required String toolTip,
  }) : super(
          parent: parent,
          name: AttributeName.toolTip,
          value: toolTip,
        ) {
    validate(toolTip);
  }

  validate(String text) {
    if (text.trim().isEmpty) {
      throw Exception('ToolTip may not be empty');
    }
  }
}

class ToolTipAttributeRule extends AttributeRule {
  ToolTipAttributeRule() : super(AttributeName.toolTip, required: false);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    return Future.value(ToolTipAttribute(
      parent: parent,
      toolTip: stringValueFor(match),
    ));
  }
}

/// A [Badge] can have a [LabelAttribute].
/// The label is the left text of the [Badge] and is often lower case text
///
/// [LabelAttribute] example: label='license'
class LabelAttribute extends Attribute<String> {
  LabelAttribute({
    required ParentNode parent,
    required String label,
  }) : super(
          parent: parent,
          name: AttributeName.label,
          value: label,
        ) {
    validate(label);
  }

  validate(String text) {
    if (text.trim().isEmpty) {
      throw Exception('Label may not be empty');
    }
  }
}

class LabelAttributeRule extends AttributeRule {
  LabelAttributeRule() : super(AttributeName.label, required: true);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    return Future.value(LabelAttribute(
      parent: parent,
      label: stringValueFor(match),
    ));
  }
}

/// A [Badge] can have a [MessageAttribute].
/// The message is the right text of the [Badge] and can have back color
///
/// [MessageAttribute] example: text='MIT'
class MessageAttribute extends Attribute<String> {
  MessageAttribute({
    required ParentNode parent,
    required String message,
  }) : super(
          parent: parent,
          name: AttributeName.message,
          value: message,
        ) {
    validate(message);
  }

  validate(String text) {
    if (text.trim().isEmpty) {
      throw Exception('Message may not be empty');
    }
  }
}

class MessageAttributeRule extends AttributeRule {
  MessageAttributeRule() : super(AttributeName.message, required: true);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    return Future.value(MessageAttribute(
      parent: parent,
      message: stringValueFor(match),
    ));
  }
}

/// A [Badge] can have a [ColorAttribute].
/// The message is the right text of the [Badge] and can have back color:
///
/// The color can be defined in different ways:
/// As color name:
/// - brightgreen
/// - green
/// - yellowgreen
/// - yellow
/// - orange
/// - red
/// - blue
/// - lightgrey
/// - blueviolet
///
/// As name
/// - success
/// - important
/// - critical
/// - informational (=default)
/// - inactive
///
/// as code:
/// - ff69b4
/// - 9cf
///
/// [ColorAttribute] example: color='important'
class ColorAttribute extends Attribute<String> {
  ColorAttribute({
    required ParentNode parent,
    required String color,
  }) : super(
          parent: parent,
          name: AttributeName.color,
          value: color,
        ) {
    validate(color);
  }

  validate(String text) {
    if (text.trim().isEmpty) {
      throw Exception('Color may not be empty');
    }
  }
}

class ColorAttributeRule extends AttributeRule {
  ColorAttributeRule() : super(AttributeName.color, required: false);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    return Future.value(ColorAttribute(
      parent: parent,
      color: stringValueFor(match),
    ));
  }
}

/// A [Badge] can have a [LinkAttribute].
/// It is a Uri that points to a web site page.
///
/// [MessageAttribute] example: uri='https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE'
class LinkAttribute extends Attribute<Uri> {
  LinkAttribute({
    required ParentNode parent,
    required Uri link,
  }) : super(
          parent: parent,
          name: AttributeName.link,
          value: link,
        );
}

class LinkAttributeRule extends AttributeRule {
  LinkAttributeRule() : super(AttributeName.link, required: true);

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
    return Future.value(LinkAttribute(
      parent: parent,
      link: Uri.parse(stringValueFor(match)),
    ));
  }
}

/// [Badge]s are images with text that inform the user on the technology used in a project and other relevant information such as links to
/// - code repository
/// - project licence
/// - documentation
/// - application stores
/// - ect...
///
/// There are different types of badges. [Badge]s in [TemplateFile]s :
/// - are surrounded by square brackets: []
/// - start with a name: e.g.  [Badge &rsqb;
/// - may have [Attribute]s after the name
///
/// e.g.: [Badge label='license' message='MIT' color='informational' link='https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE' &rsqb;
/// [![GitHub License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE)

abstract class Badge extends Node {
  final String? toolTip;
  final Uri image;
  final Uri link;

  static Uri imgShieldIoUri = Uri.parse('https://img.shields.io/');

  Badge({
    ParentNode? parent,
    this.toolTip,
    required this.image,
    required this.link,
  }) : super(parent);

  @override
  String toString() {
    String toolTipMarkDown = toolTip == null ? '' : '[$toolTip]';
    return "[!$toolTipMarkDown($image)]($link)";
  }
}

abstract class BadgeRule extends TextParserRule {
  final List<AttributeRule> attributeRules;

  BadgeRule(String name, this.attributeRules) : super(createExpression(name));

  static FluentRegex createExpression(String name) => FluentRegex()
      .literal('[')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(name)
      .group(
          // using direct expression because CharacterSet is missing characters such as new line
          // attributes are required therefore one or more times
          FluentRegex('[^\\n\\]]+'),
          type: GroupType.captureNamed(GroupName.attributes))
      .literal(']')
      .ignoreCase();

  @override
  Future<Node> createReplacementNode(
      ParentNode parent, RegExpMatch match) async {
    try {
      String attributesText = match.namedGroup(GroupName.attributes) ?? '';
      var tagAttributeParser = AttributeParser(attributeRules);
      Map<String, dynamic> attributes =
          await tagAttributeParser.parseToNameAndValues(attributesText);
      return createBadgeNode(parent, attributes);
    } on ParserWarning catch (warning) {
      // Wrap warning with tag information, so it can be found easily
      throw ParserWarning("$warning in badge: '${match.result}'.");
    }
  }

  Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes);
}

/// - **[CustomBadge  tooltip='GitHub License' label='license' message='MIT' link='https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE'  &rsqb;**
/// - Creates a CustomBadge that is defined with customizable [Attribute]s.
/// - E.g.: [![GitHub License](https://img.shields.io//badge/license-MIT-informational)](https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE)
/// - Attributes:
///   - optional [ToolTipAttribute]
///   - required [LabelAttribute]
///   - required [MessageAttribute]
///   - optional [ColorAttribute]
///   - required [LinkAttribute]
class CustomBadge extends Badge {
  CustomBadge({
    ParentNode? parent,

    /// See [ToolTipAttribute]
    String? toolTip,

    /// See [LabelAttribute]
    required String label,

    /// See [MessageAttribute]
    required String message,

    /// See [ColorAttribute]
    String color = 'informational',
    required Uri link,
  }) : super(
            parent: parent,
            toolTip: toolTip,
            image: Badge.imgShieldIoUri
                .withPathSuffix('badge/$label-$message-$color'),
            link: link);
}

class CustomBadgeRule extends BadgeRule {
  CustomBadgeRule()
      : super('custombadge', [
          ToolTipAttributeRule(),
          LabelAttributeRule(),
          MessageAttributeRule(),
          ColorAttributeRule(),
          LinkAttributeRule(),
        ]);

  @override
  Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
    String? toolTip = attributes[AttributeName.toolTip];
    String label = attributes[AttributeName.label];
    String message = attributes[AttributeName.message];
    String color = attributes[AttributeName.color] ?? 'informational';
    Uri link = attributes[AttributeName.link];
    return CustomBadge(
      parent: parent,
      toolTip: toolTip,
      label: label,
      message: message,
      color: color,
      link: link,
    );
  }
}
