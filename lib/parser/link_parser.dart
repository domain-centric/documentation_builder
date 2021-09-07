import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/builders/template_builder.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// The [LinkParser] searches for [TextNode]'s that contain texts that represent a [Link]
/// It then replaces these [TextNode]'s into a [Link] and additional [TextNode]'s for the remaining text.
class LinkParser extends Parser {
  LinkParser()
      : super([
          CompleteLinkRule(),
          GitHubProjectLinkRule(),
          //TODO
        ]);
}

/// A text between square brackets [] followed by a [Uri] between parentheses (),
/// These will be replaced by a complete [Link]
/// Example: [Search the webt&rsqb;(https://google.com)
///
/// This Rule was added and will be parces first to prevent complete links
/// to be replaced by incomplete links
class CompleteLinkRule extends TextParserRule {
  CompleteLinkRule() : super(createExpression());

  static String groupNameTitle = 'title';
  static String groupNameUri = 'uri';

  static FluentRegex createExpression() => FluentRegex()
      .literal('[')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed(groupNameTitle))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(']')
      .literal('(')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed(groupNameUri))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(')')
      .ignoreCase();

  @override
  Future<Node> createReplacementNode(
      ParentNode parent, RegExpMatch match) async {
    try {
      String title = match.namedGroup(groupNameTitle) ?? ''.trim();
      Uri uri = Uri.parse(match.namedGroup(groupNameUri) ?? '');
      return Link(parent: parent, title: title, uri: uri);
    } on ParserWarning catch (warning) {
      // Wrap warning with link information, so it can be easily found
      throw ParserWarning("$warning in link: '${match.result}'.");
    }
  }
}

/// A text between square brackets [] but not followed by a [Uri] between parentheses (),
/// These will be replaced by a complete [Link]
/// Example: [GitHub&rsqb; would be replaced by [GitHub project&rsqb;(https://github.com/efficientyboosters/documentation_builder)
abstract class InCompleteLinkRule extends TextParserRule {
  final List<AttributeRule> attributeRules;
  static final FluentRegex defaultNameExpression = FluentRegex().characterSet(
      CharacterSet().addLetters().addDigits(), Quantity.oneOrMoreTimes());

  InCompleteLinkRule(this.attributeRules, {required FluentRegex nameExpression})
      : super(createExpression(nameExpression));

  static String groupNameName = 'name';
  static String groupNameAttributes = 'attributes';

  static FluentRegex createExpression(FluentRegex nameExpression) {
    return FluentRegex()
        .literal('[')
        .whiteSpace(Quantity.zeroOrMoreTimes())
        .group(
          nameExpression,
          type: GroupType.captureNamed(groupNameName),
        )
        .group(
            FluentRegex()
                .whiteSpace()
                .anyCharacter(Quantity.oneOrMoreTimes().reluctant),
            type: GroupType.captureNamed(groupNameAttributes))
        .literal(']')
        .ignoreCase();
  }


  @override
  Future<Node> createReplacementNode(
      ParentNode parent, RegExpMatch match) async {
    try {
      String name = match.namedGroup(groupNameName)!;
      String attributesText = match.namedGroup(groupNameAttributes) ?? '';
      var tagAttributeParser = TagAttributeParser(attributeRules);
      Map<String, dynamic> attributes =
          await tagAttributeParser.parseToNameAndValues(attributesText);
      var linkNode = createLinkNode(parent, name, attributes);
      await linkNode.validateUriHttpGet();
      return linkNode;
    } on ParserWarning catch (warning) {
      // Wrap warning with link information, so it can be easily found
      throw ParserWarning("$warning in link: '${match.result}'.");
    }
  }

  Link createLinkNode(
    ParentNode parent,
    String name,
    Map<String, dynamic> attributeNamesAndValues,
  );
}

/// You can refer to other parts of the documentation using [Link]s.
/// [Link]s:
/// - are references between square brackets [] in [MarkdownTemplateFile]s, e.g.: [MyClass]
/// - can have optional or required attributes, e.g. []
///
/// The [DocumentationBuilder] will try to convert these to hyperlinks that point to an existing http uri.
/// The [Link] will not be replaced to a hyperlink when the uri does not exits.
class Link extends ParentNode {
  final String title;
  final Uri uri;

  Link({
    ParentNode? parent,
    required this.title,
    required this.uri,
  }) : super(parent) {
    validateTitle();
  }

  @override
  String toString() {
    return '[$title]($uri)';
  }

  void validateTitle() {
    if (title.trim().isEmpty)
      throw ParserWarning('The title attribute may not be empty');
  }

  /// This method is called by [CompleteLinkRule.createReplacementNodes]
  /// because it is a async method.
  Future<void> validateUriHttpGet() async {
    if (!await uri.canGetWithHttp())
      throw ParserWarning('Could not get uri: $uri');
  }
}

/// abstract link rule with optional TitleAttribute
abstract class LinkDefinitionsRule extends InCompleteLinkRule {
  final List<LinkDefinition> linkDefinitions;

  LinkDefinitionsRule(this.linkDefinitions)
      : super([
          UriSuffixAttributeRule(),
          TitleAttributeRule(),
        ], nameExpression: createNameExpression(linkDefinitions));

  static FluentRegex createNameExpression(
      List<LinkDefinition> linkDefinitions) {
    var nameExpressions = linkDefinitions
        .map((linkDef) => FluentRegex().literal(linkDef.name))
        .toList();
    return FluentRegex().or(nameExpressions).ignoreCase();
  }

  @override
  Link createLinkNode(
      ParentNode parent, String name, Map<String, dynamic> attributes) {
    LinkDefinition linkDef = linkDefinitions.firstWhere(
        (linkDef) => linkDef.name.toLowerCase() == name.toLowerCase());
    String title = findTitle(linkDef, attributes);
    Uri uri = createUri(linkDef, attributes);
    return Link(parent: parent, title: title, uri: uri);
  }

  Uri createUri(LinkDefinition linkDef, Map<String, dynamic> attributes) {
    Uri uri = linkDef.uri;
    final String name = UriSuffixAttributeRule().name;
    if (attributes.keys.contains(name)) {
      UriSuffixPath suffix = attributes[name];
      uri = uri.withPathSuffix(suffix.path);
    }
    return uri;
  }

  String findTitle(LinkDefinition linkDef, Map<String, dynamic> attributes) {
    final String name = TitleAttributeRule().name;
    if (attributes.keys.contains(name)) {
      return attributes[name];
    } else {
      return linkDef.defaultTitle;
    }
  }
}

class LinkDefinition {
  final String name;
  final String defaultTitle;
  final Uri uri;

  LinkDefinition({
    required this.name,
    required this.defaultTitle,
    required this.uri,
  });
}

/// [GitHubProjectLink]s point to a [GitHub](https://github.com/) page of the
/// current project (assuming it is stored on GitHub).
///
/// You can use the following MarkDown:
/// [GitHub&rsqb;
/// [GitHubWiki&rsqb;
/// [GitHubMilestones&rsqb;
/// [GitHubVersions&rsqb;
/// [GitHubPullRequests&rsqb;
///
/// You can the following optional attributes:
/// - suffix: A path suffix e.g. [Github suffix='wiki'&rsqb; is the same as [GithubWiki&rsqb;
/// - title: An alternative title for the hyperlink. e.g. [GitHubWiki title='# Wiki documentation'&rsqb;
class GitHubProjectLinkRule extends LinkDefinitionsRule {
  GitHubProjectLinkRule()
      : super(GitHubProject().linkDefinitions);
}

///TODO PUBSPECRULES

/// A library can have members such as a:
/// - constant
/// - function
/// - enum (an enum can have value members)
/// - class (a class can have members such as methods, fields, and field access methods)
/// - extension (an extension can have members such as methods, fields, and field access methods)
///
/// These library members can be referred to in [MarkdownPage]'s using brackets. e.g.
/// - [myConstant]
/// - [myFunction]
/// - [MyEnum]
///   - [MyEnum.myValue]
/// - [MyClass]
///   - [MyClass.myField]
///   - [MyClass.get.myField]
///   - [MyClass.set.myField]
///   - [MyClass.myMethod]
/// - [MyExtension]
///   - [MyClass.myField]
///   - [MyExtension.get.myField]
///   - [MyExtension.set.myField]
///   - [MyExtension.myMethod]
/// You can also include the library name in case a project uses same member names in different libraries, e.g.:
/// - [MyLib/myConstant]
/// - [MyLib/myFunction]
/// - etc.
///
/// The [DocumentationBuilder] will try to resolve these [MemberLink]s in the following order:
/// - Within the [MarkdownPage], e.g.: link it to the position of a [ImportDartDocTag]
/// - Within another [WikiMarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
/// - Link it to a [GitHubProjectCodeLink]
/// The [Link] will not be replaced when the [Link] can not be resolved
//TODO MemberLinkRule
//TODO MarkDownFileLinkRule
//TODO PubDevLinkRule
//TODO PREVIOUS_HOME_NEXT LINKS FOR WIKI PAGES
