// import 'package:documentation_builder/src/generic/documentation_model.dart';
// import 'package:documentation_builder/src/generic/paths.dart';
// import 'package:documentation_builder/src/parser/attribute_parser.dart';
// import 'package:documentation_builder/src/parser/parser.dart';
// import 'package:documentation_builder/src/engine/path/github_project.dart';
// import 'package:documentation_builder/src/engine/path/local_project.dart';
// import 'package:documentation_builder/src/engine/path/pub_dev_project.dart';
// import 'package:fluent_regex/fluent_regex.dart';

// /// The [BadgeParser] searches for [TextNode]'s that contain texts that represent a [Badge]
// /// It then replaces these [TextNode]'s into a [Badge] and additional [TextNode]'s for the remaining text.
// class BadgeParser extends Parser {
//   BadgeParser()
//       : super([
//           CustomBadgeRule(),
//           PubPackageBadgeRule(),
//           GitHubBadgeRule(),
//           GitHubWikiBadgeRule(),
//           GitHubStarsBadgeRule(),
//           GitHubIssuesBadgeRule(),
//           GitHubPullRequestsBadgeRule(),
//           GitHubLicenseBadgeRule(),
//         ]);
// }

// /// A [Badge] can have a [ToolTipAttribute].
// /// This text becomes visible when hoovering over a [Badge]
// ///
// /// [ToolTipAttribute] example: tooltip='MIT License'
// class ToolTipAttribute extends Attribute<String> {
//   ToolTipAttribute({
//     required ParentNode parent,
//     required String toolTip,
//   }) : super(
//           parent: parent,
//           name: AttributeName.toolTip,
//           value: toolTip,
//         ) {
//     validate(toolTip);
//   }

//   validate(String text) {
//     if (text.trim().isEmpty) {
//       throw Exception('ToolTip may not be empty');
//     }
//   }
// }

// class ToolTipAttributeRule extends AttributeRule {
//   ToolTipAttributeRule() : super(AttributeName.toolTip, required: false);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(ToolTipAttribute(
//       parent: parent,
//       toolTip: stringValueFor(match),
//     ));
//   }
// }

// /// A [GitHubLicenseBadge] can have a licenseType attribute.
// /// This text is displayed on the [Badge].
// /// By default this value is 'MIT'.
// ///
// /// [LicenseTypeAttribute] example: licenseType='GNU'
// class LicenseTypeAttribute extends Attribute<String> {
//   LicenseTypeAttribute({
//     required ParentNode parent,
//     required String licenseType,
//   }) : super(
//           parent: parent,
//           name: AttributeName.licenseType,
//           value: licenseType,
//         ) {
//     validate(licenseType);
//   }

//   validate(String text) {
//     if (text.trim().isEmpty) {
//       throw Exception('LicenseType may not be empty');
//     }
//   }
// }

// class LicenseTypeAttributeRule extends AttributeRule {
//   LicenseTypeAttributeRule()
//       : super(AttributeName.licenseType, required: false);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(LicenseTypeAttribute(
//       parent: parent,
//       licenseType: stringValueFor(match),
//     ));
//   }
// }

// /// A [Badge] can have a [LabelAttribute].
// /// The label is the left text of the [Badge] and is often lower case text
// ///
// /// [LabelAttribute] example: label='license'
// class LabelAttribute extends Attribute<String> {
//   LabelAttribute({
//     required ParentNode parent,
//     required String label,
//   }) : super(
//           parent: parent,
//           name: AttributeName.label,
//           value: label,
//         ) {
//     validate(label);
//   }

//   validate(String text) {
//     if (text.trim().isEmpty) {
//       throw Exception('Label may not be empty');
//     }
//   }
// }

// class LabelAttributeRule extends AttributeRule {
//   LabelAttributeRule() : super(AttributeName.label, required: true);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(LabelAttribute(
//       parent: parent,
//       label: stringValueFor(match),
//     ));
//   }
// }

// /// A [Badge] can have a [MessageAttribute].
// /// The message is the right text of the [Badge] and can have back color
// ///
// /// [MessageAttribute] example: text='MIT'
// class MessageAttribute extends Attribute<String> {
//   MessageAttribute({
//     required ParentNode parent,
//     required String message,
//   }) : super(
//           parent: parent,
//           name: AttributeName.message,
//           value: message,
//         ) {
//     validate(message);
//   }

//   validate(String text) {
//     if (text.trim().isEmpty) {
//       throw Exception('Message may not be empty');
//     }
//   }
// }

// class MessageAttributeRule extends AttributeRule {
//   MessageAttributeRule() : super(AttributeName.message, required: true);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(MessageAttribute(
//       parent: parent,
//       message: stringValueFor(match),
//     ));
//   }
// }

// /// A [Badge] can have a [ColorAttribute].
// /// The message is the right text of the [Badge] and can have back color:
// ///
// /// The color can be defined in different ways:
// /// As color name:
// /// - brightgreen
// /// - green
// /// - yellowgreen
// /// - yellow
// /// - orange
// /// - red
// /// - blue
// /// - lightgrey
// /// - blueviolet
// ///
// /// As name
// /// - success
// /// - important
// /// - critical
// /// - informational (=default)
// /// - inactive
// ///
// /// as code:
// /// - ff69b4
// /// - 9cf
// ///
// /// [ColorAttribute] example: color='important'
// class ColorAttribute extends Attribute<String> {
//   ColorAttribute({
//     required ParentNode parent,
//     required String color,
//   }) : super(
//           parent: parent,
//           name: AttributeName.color,
//           value: color,
//         ) {
//     validate(color);
//   }

//   validate(String text) {
//     if (text.trim().isEmpty) {
//       throw Exception('Color may not be empty');
//     }
//   }
// }

// class ColorAttributeRule extends AttributeRule {
//   ColorAttributeRule() : super(AttributeName.color, required: false);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(ColorAttribute(
//       parent: parent,
//       color: stringValueFor(match),
//     ));
//   }
// }

// /// A [Badge] can have a [LinkAttribute].
// /// It is a Uri that points to a web site page.
// ///
// /// [MessageAttribute] example: uri='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE'
// class LinkAttribute extends Attribute<Uri> {
//   LinkAttribute({
//     required ParentNode parent,
//     required Uri link,
//   }) : super(
//           parent: parent,
//           name: AttributeName.link,
//           value: link,
//         );
// }

// class LinkAttributeRule extends AttributeRule {
//   LinkAttributeRule() : super(AttributeName.link, required: true);

//   @override
//   Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) {
//     return Future.value(LinkAttribute(
//       parent: parent,
//       link: Uri.parse(stringValueFor(match)),
//     ));
//   }
// }

// /// [Badge]s are images with text that inform the user on the technology used in a project and other relevant information such as links to
// /// - code repository
// /// - project license
// /// - documentation
// /// - application stores
// /// - ect...
// ///
// /// There are different types of badges. [Badge]s in [TemplateFile]s :
// /// - are surrounded by square brackets: []
// /// - start with a ! and a name: e.g.  [!CustomBadge &rsqb;
// /// - may have [Attribute]s after the name
// ///
// /// e.g.: [!CustomBadge label='license' message='MIT' color='informational' link='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE' &rsqb;
// /// [![GitHub License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)

// abstract class Badge extends Node {
//   final String? toolTip;
//   final Uri image;
//   final Uri link;

//   static Uri imgShieldIoUri = Uri.parse('https://img.shields.io');

//   Badge({
//     ParentNode? parent,
//     this.toolTip,
//     required this.image,
//     required this.link,
//   }) : super(parent);

//   @override
//   String toString() {
//     String toolTipMarkDown = toolTip == null ? '' : '[$toolTip]';
//     return "[!$toolTipMarkDown($image)]($link)";
//   }
// }

// abstract class BadgeRule extends TextParserRule {
//   final List<AttributeRule> attributeRules;

//   BadgeRule(String name, this.attributeRules) : super(createExpression(name));

//   static FluentRegex createExpression(String name) => FluentRegex()
//       .literal('[')
//       .whiteSpace(Quantity.zeroOrMoreTimes())
//       .literal('!')
//       .whiteSpace(Quantity.zeroOrMoreTimes())
//       .literal(name)
//       .group(
//           // using direct expression because CharacterSet is missing characters such as new line
//           FluentRegex('[^\$newLine\\]]*'),
//           type: GroupType.captureNamed(GroupName.attributes))
//       .literal(']')
//       .ignoreCase();

//   @override
//   Future<Node> createReplacementNode(
//       ParentNode parent, RegExpMatch match) async {
//     try {
//       String attributesText = match.namedGroup(GroupName.attributes) ?? '';
//       var tagAttributeParser = AttributeParser(attributeRules);
//       Map<String, dynamic> attributes =
//           await tagAttributeParser.parseToNameAndValues(attributesText);
//       return createBadgeNode(parent, attributes);
//     } on ParserWarning catch (warning) {
//       // Wrap warning with tag information, so it can be found easily
//       throw ParserWarning("$warning in badge: '${match.result}'.");
//     }
//   }

//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes);
// }

// /// - **[CustomBadge  tooltip='GitHub License' label='license' message='MIT' link='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE'  &rsqb;**
// /// - Creates a [CustomBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// ///   - required [LabelAttribute]
// ///   - required [MessageAttribute]
// ///   - optional [ColorAttribute]
// ///   - required [LinkAttribute]
// class CustomBadge extends Badge {
//   CustomBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,

//     /// See [LabelAttribute]
//     required String label,

//     /// See [MessageAttribute]
//     required String message,

//     /// See [ColorAttribute]
//     String color = 'informational',
//     required Uri link,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip,
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('badge/$label-$message-$color'),
//             link: link);
// }

// class CustomBadgeRule extends BadgeRule {
//   CustomBadgeRule()
//       : super('custombadge', [
//           ToolTipAttributeRule(),
//           LabelAttributeRule(),
//           MessageAttributeRule(),
//           ColorAttributeRule(),
//           LinkAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     String label = attributes[AttributeName.label];
//     String message = attributes[AttributeName.message];
//     String color = attributes[AttributeName.color] ?? 'informational';
//     Uri link = attributes[AttributeName.link];
//     return CustomBadge(
//       parent: parent,
//       toolTip: toolTip,
//       label: label,
//       message: message,
//       color: color,
//       link: link,
//     );
//   }
// }

// /// - **[PubPackageBadge&rsqb;**
// /// - Creates a [PubPackageBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![Pub Package](https://img.shields.io/pub/v/documentation_builder)](https://pub.dev/packages/documentation_builder)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class PubPackageBadge extends Badge {
//   PubPackageBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'Pub Package',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('pub/v/${LocalProject.name}'),
//             link: PubDevProject().uri!);
// }

// class PubPackageBadgeRule extends BadgeRule {
//   PubPackageBadgeRule()
//       : super('PubPackageBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return PubPackageBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubBadge&rsqb;**
// /// - Creates a [GitHubBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/documentation_builder)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class GitHubBadge extends Badge {
//   GitHubBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'Code Repository',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('badge/repository-git%20hub-informational'),
//             link: GitHubProject().uri!);
// }

// class GitHubBadgeRule extends BadgeRule {
//   GitHubBadgeRule()
//       : super('GitHubBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return GitHubBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubWikiBadge&rsqb;**
// /// - Creates a [GitHubWikiBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/documentation_builder/wiki)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class GitHubWikiBadge extends Badge {
//   GitHubWikiBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'Github Wiki',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('badge/documentation-wiki-informational'),
//             link: GitHubProject().wikiUri!);
// }

// class GitHubWikiBadgeRule extends BadgeRule {
//   GitHubWikiBadgeRule()
//       : super('GitHubWikiBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return GitHubWikiBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubStarsBadge&rsqb;**
// /// - Creates a [GitHubStarsBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![GitHub Stars](https://img.shields.io/github/stars/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/stargazers)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class GitHubStarsBadge extends Badge {
//   GitHubStarsBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'GitHub Stars',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('github/stars${GitHubProject().uri!.path}'),
//             link: GitHubProject().stargazersUri!);
// }

// class GitHubStarsBadgeRule extends BadgeRule {
//   GitHubStarsBadgeRule()
//       : super('GitHubStarsBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return GitHubStarsBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubIssuesBadge&rsqb;**
// /// - Creates a [GitHubStarsBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![GitHub Issues](https://img.shields.io/github/issues/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/issues)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class GitHubIssuesBadge extends Badge {
//   GitHubIssuesBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'GitHub Issues',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('github/issues${GitHubProject().uri!.path}'),
//             link: GitHubProject().issuesUri!);
// }

// class GitHubIssuesBadgeRule extends BadgeRule {
//   GitHubIssuesBadgeRule()
//       : super('GitHubIssuesBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return GitHubIssuesBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubPullRequestsBadge&rsqb;**
// /// - Creates a [GitHubPullRequestsBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![GitHub Pull Requests](https://img.shields.io/github/issues-pr/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/pull)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// class GitHubPullRequestsBadge extends Badge {
//   GitHubPullRequestsBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'GitHub Pull Requests',
//             image: Badge.imgShieldIoUri
//                 .withPathSuffix('github/issues-pr${GitHubProject().uri!.path}'),
//             link: GitHubProject().pullRequestsUri!);
// }

// class GitHubPullRequestsBadgeRule extends BadgeRule {
//   GitHubPullRequestsBadgeRule()
//       : super('GitHubPullRequestsBadge', [
//           ToolTipAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     return GitHubPullRequestsBadge(parent: parent, toolTip: toolTip);
//   }
// }

// /// - **[GitHubLicenseBadge&rsqb;**
// /// - Creates a [GitHubLicenseBadge] that is defined with customizable [Attribute]s.
// /// - E.g.: [![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)
// /// - Attributes:
// ///   - optional [ToolTipAttribute]
// ///   - optional [LicenseTypeAttributeRule]
// class GitHubLicenseBadge extends Badge {
//   GitHubLicenseBadge({
//     ParentNode? parent,

//     /// See [ToolTipAttribute]
//     String? toolTip,
//     String? licenseType,
//   }) : super(
//             parent: parent,
//             toolTip: toolTip ?? 'GitHub License',
//             image: Badge.imgShieldIoUri.withPathSuffix(
//                 'badge/license-${licenseType ?? 'MIT'}-informational'),
//             link: GitHubProject().license()!);
// }

// class GitHubLicenseBadgeRule extends BadgeRule {
//   GitHubLicenseBadgeRule()
//       : super('GitHubLicenseBadge', [
//           ToolTipAttributeRule(),
//           LicenseTypeAttributeRule(),
//         ]);

//   @override
//   Badge createBadgeNode(ParentNode parent, Map<String, dynamic> attributes) {
//     String? toolTip = attributes[AttributeName.toolTip];
//     String? licenseType = attributes[AttributeName.licenseType];
//     return GitHubLicenseBadge(
//         parent: parent, toolTip: toolTip, licenseType: licenseType);
//   }
// }
