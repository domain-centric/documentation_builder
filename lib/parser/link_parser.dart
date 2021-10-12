import 'package:collection/collection.dart';
import 'package:documentation_builder/builder/documentation_builder.dart';
import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/attribute_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// The [LinkParser] searches for [TextNode]'s that contain texts that represent a [Link]
/// It then replaces these [TextNode]'s into a [Link] and additional [TextNode]'s for the remaining text.
class LinkParser extends Parser {
  LinkParser()
      : super([
          CompleteLinkRule(),
          GitHubProjectLinkRule(),
          PubDevProjectLinkRule(),
          PubDevPackageLinkRule(),
          DartCodeLinkRule(),
          MarkdownFileLinkRule(),
          //TODO PreviousHomeNextRule(),
        ]);
}

/// A complete Hyperlink in Markdown is a text between square brackets []
/// followed by a Uri between parentheses (),
///
/// e.g.: [Search the webt&rsqb;(https://google.com)

class CompleteLink extends Link {
  CompleteLink(ParentNode parent, RegExpMatch match)
      : super(parent: parent, uri: createUri(match), title: createTitle(match));

  static createUri(RegExpMatch match) =>
      Uri.parse(match.namedGroup(GroupName.uri) ?? '');

  static createTitle(RegExpMatch match) =>
      match.namedGroup(GroupName.title) ?? ''.trim();
}

/// This Rule was added and will be parses first to prevent complete links
/// to be replaced by incomplete links
class CompleteLinkRule extends TextParserRule {
  CompleteLinkRule() : super(createExpression());

  static FluentRegex createExpression() => FluentRegex()
      .literal('[')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed(GroupName.title))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(']')
      .literal('(')
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .group(FluentRegex().anyCharacter(Quantity.zeroOrMoreTimes().reluctant),
          type: GroupType.captureNamed(GroupName.uri))
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal(')')
      .ignoreCase();

  @override
  Future<Node> createReplacementNode(
          ParentNode parent, RegExpMatch match) async =>
      CompleteLink(parent, match);
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

  static FluentRegex createExpression(FluentRegex nameExpression) {
    return FluentRegex()
        .literal('[')
        .whiteSpace(Quantity.zeroOrMoreTimes())
        .group(
          nameExpression,
          type: GroupType.captureNamed(GroupName.name),
        )
        .group(
            FluentRegex().whiteSpace(Quantity.oneOrMoreTimes()).characterSet(
                CharacterSet.exclude().addLiterals(']['),
                Quantity.oneOrMoreTimes()),
            quantity: Quantity.zeroOrMoreTimes(),
            type: GroupType.captureNamed(GroupName.attributes))
        .whiteSpace(Quantity.zeroOrMoreTimes())
        .literal(']')
        .ignoreCase();
  }

  @override
  Future<Node> createReplacementNode(
      ParentNode parent, RegExpMatch match) async {
    try {
      String name = match.namedGroup(GroupName.name)!;
      String attributesText = match.namedGroup(GroupName.attributes) ?? '';
      var attributeParser = AttributeParser(attributeRules);
      Map<String, dynamic> attributes =
          await attributeParser.parseToNameAndValues(attributesText);
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
    Map<String, dynamic> attributes,
  );
}

/// You can refer to other parts of the documentation using [Link]s.
/// [Link]s:
/// - are references between square brackets [] in [TemplateFile]s, e.g.: [MyClass&rsqb;
/// - can have optional or required attributes, e.g.: [MyClass title='Link to my class'&rsqb;
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

  /// This method is called by [CompleteLink.createReplacementNodes]
  /// because it is a async method.
  Future<void> validateUriHttpGet() async {
    if (!await uri.canGetWithHttp())
      throw ParserWarning('Could not get uri: $uri');
  }

  static String createTitle(
      String defaultTitle, Map<String, dynamic> attributes) {
    final String nameAttribute = TitleAttributeRule().name;
    if (attributes.keys.contains(nameAttribute)) {
      return attributes[nameAttribute];
    } else {
      return defaultTitle;
    }
  }

  static Uri createUri(Uri defaultUri, Map<String, dynamic> attributes) {
    final String name = AttributeName.suffix;
    if (attributes.keys.contains(name)) {
      UriSuffixPath suffix = attributes[name];
      return defaultUri.withPathSuffix(suffix.path);
    }
    return defaultUri;
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
}

class LinkDefinition {
  final String name;
  final String defaultTitle;
  final Uri uri;

  const LinkDefinition({
    required this.name,
    required this.defaultTitle,
    required this.uri,
  });
}

/// [GitHubProjectLink]s point to a [GitHub](https://github.com/) page of the
/// current project (assuming it is stored on GitHub).
///
/// You can use the following MarkDown:
/// - [GitHub&rsqb;
/// - [GitHubWiki&rsqb;
/// - [GitHubMilestones&rsqb;
/// - [GitHubReleases&rsqb;
/// - [GitHubPullRequests&rsqb;
/// - [GitHubRaw&rsqb;
///
/// You can the following optional attributes:
/// - suffix: A path suffix e.g. [Github suffix='wiki'&rsqb; is the same as [GithubWiki&rsqb;
/// - title: An alternative title for the hyperlink. e.g. [GitHubWiki title='Wiki documentation'&rsqb;

class GitHubProjectLink extends Link {
  GitHubProjectLink(
    ParentNode parent,
    LinkDefinition linkDef,
    Map<String, dynamic> attributes,
  ) : super(
            parent: parent,
            title: createTitle(linkDef, attributes),
            uri: createUri(linkDef, attributes));

  static String createTitle(
      LinkDefinition linkDef, Map<String, dynamic> attributes) {
    final String nameAttribute = TitleAttributeRule().name;
    if (attributes.keys.contains(nameAttribute)) {
      return attributes[nameAttribute];
    } else {
      return linkDef.defaultTitle;
    }
  }

  static Uri createUri(
      LinkDefinition linkDef, Map<String, dynamic> attributes) {
    Uri uri = linkDef.uri;
    final String name = AttributeName.suffix;
    if (attributes.keys.contains(name)) {
      UriSuffixPath suffix = attributes[name];
      uri = uri.withPathSuffix(suffix.path);
    }
    return uri;
  }
}

class GitHubProjectLinkRule extends LinkDefinitionsRule {
  GitHubProjectLinkRule() : super(GitHubProject().linkDefinitions);

  @override
  Link createLinkNode(
      ParentNode parent, String name, Map<String, dynamic> attributes) {
    LinkDefinition linkDef = linkDefinitions.firstWhere(
        (linkDef) => linkDef.name.toLowerCase() == name.toLowerCase());
    return GitHubProjectLink(parent, linkDef, attributes);
  }
}

/// [GitHubProjectLink]s point to a [PubDev](https://pub.dev/) page of the
/// current project (assuming it is published on PubDev).
///
/// You can use the following MarkDown:
/// - [PubDev&rsqb;
/// - [PubDevChangeLog&rsqb;
/// - [PubDevVersions&rsqb;
/// - [PubDevExample&rsqb;
/// - [PubDevInstall&rsqb;
/// - [PubDevScore&rsqb;
/// - [PubDevLicense&rsqb;
///
/// You can the following optional attributes:
/// - suffix: A path suffix e.g. [PubDev suffix='example'&rsqb; is the same as [PubDevExample&rsqb;
/// - title: An alternative title for the hyperlink. e.g. [PubDevExample title='Examples'&rsqb;
class PubDevProjectLink extends Link {
  PubDevProjectLink(
    ParentNode parent,
    LinkDefinition linkDef,
    Map<String, dynamic> attributes,
  ) : super(
            parent: parent,
            title: Link.createTitle(linkDef.defaultTitle, attributes),
            uri: Link.createUri(linkDef.uri, attributes));
}

class PubDevProjectLinkRule extends LinkDefinitionsRule {
  PubDevProjectLinkRule() : super(PubDevProject().linkDefinitions);

  @override
  Link createLinkNode(
      ParentNode parent, String name, Map<String, dynamic> attributes) {
    LinkDefinition linkDef = linkDefinitions.firstWhere(
        (linkDef) => linkDef.name.toLowerCase() == name.toLowerCase());
    return PubDevProjectLink(parent, linkDef, attributes);
  }
}

/// A [PubDevPackageLink] links point to a [PubDev](https://pub.dev) package.
///
/// The [DocumentationBuilder] will check if any valid package name
/// (lower case letter, numbers and underscores) between
/// square brackets exists as a package on https://pub.dev.
///
/// It will be converter to a hyperlink if it exists. e.g.:
/// - [json_serializable&rsqb; will be replaced by
///   [json_serializable&rsqb;(https://pub.dev/packages/json_serializable)
/// - [none_existent_package] will remain the same.
///
/// You can use the optional title attribute, e.g.:
/// [json_serializable title='Package for json conversion'&rsqb; will be replaced by
/// [Package for json conversion&rsqb;(https://pub.dev/packages/json_serializable)
class PubDevPackageLink extends Link {
  PubDevPackageLink(
      ParentNode parent, String name, Map<String, dynamic> attributes)
      : super(
            parent: parent,
            title: Link.createTitle(name, attributes),
            uri: PubDevProject.forProjectName(name).uri!);
}

class PubDevPackageLinkRule extends InCompleteLinkRule {
  PubDevPackageLinkRule()
      : super(
          [TitleAttributeRule()],
          nameExpression: createNameExpression(),
        );

  @override
  Future<List<RegExpMatch>> createMatches(TextNode textNode) async =>
      await pubDevPackageMatches(textNode);

  @override
  Link createLinkNode(
      ParentNode parent, String name, Map<String, dynamic> attributes) {
    return PubDevPackageLink(parent, name, attributes);
  }

  static FluentRegex createNameExpression() => FluentRegex().characterSet(
      CharacterSet().addLetters(CaseType.lower).addDigits().addLiterals('_'),
      Quantity.oneOrMoreTimes());

  /// Returns matches that represent existing packages on https://pub.dev only
  Future<List<RegExpMatch>> pubDevPackageMatches(TextNode textNode) async {
    var matches = await super.createMatches(textNode);
    List<RegExpMatch> pubDevPackageMatches = [];
    for (RegExpMatch match in matches) {
      String tagName = match.namedGroup(GroupName.name)!;
      bool exists =
          await PubDevProject.forProjectName(tagName).uri!.canGetWithHttp();
      if (exists) pubDevPackageMatches.add(match);
    }
    return pubDevPackageMatches;
  }
}

/// A [MarkdownFileLink] links point to an other [GeneratedFile].
///
/// The [DocumentationBuilder] will try to find this [GeneratedFile] and
/// replace the link to a hyperlink with an absolute Url.
///
/// You can use :
/// - the template name e.g.: [README.mdt&rsqb;
/// - the output name e.g.: [README.md&rsqb;
/// - the [ProjectFilePath], e.g.: [doc/template/README.md&rsqb;
/// - an optional optional title attribute, e.g.:
/// [README.mdt title='About this project'&rsqb;
///
/// Note that the [DocumentationBuilder] ignores letter casing.
class MarkdownFileLink extends Link {
  MarkdownFileLink(ParentNode parent, String title, Uri uri)
      : super(parent: parent, title: title, uri: uri);
}

class MarkdownFileLinkRule extends InCompleteLinkRule {
  MarkdownFileLinkRule()
      : super([TitleAttributeRule()],
            nameExpression:
                ProjectFilePath.expression.startOfLine(false).endOfLine(false));

  @override
  Future<List<RegExpMatch>> createMatches(TextNode textNode) async =>
      await markdownFileMatches(textNode);

  @override
  Link createLinkNode(
      ParentNode parent, String path, Map<String, dynamic> attributes) {
    var defaultTitle = createDefaultTitle(path);
    String title = Link.createTitle(defaultTitle, attributes);
    Uri uri = findMarkdownTemplate(parent, path)!.destinationWebUri!;
    return MarkdownFileLink(parent, title, uri);
  }

  /// Returns matches that represent existing [GeneratedFile]s
  Future<List<RegExpMatch>> markdownFileMatches(TextNode textNode) async {
    var matches = await super.createMatches(textNode);
    List<RegExpMatch> markdownFileMatches = [];
    for (RegExpMatch match in matches) {
      String path = match.namedGroup(GroupName.name)!;
      Template? markdownTemplate = findMarkdownTemplate(textNode.parent!, path);

      if (markdownTemplate != null) markdownFileMatches.add(match);
    }
    return markdownFileMatches;
  }

  /// finds a [Template] with a sourceFilePath or destinationFilePath
  /// that ends with path, while ignoring upper or lower case.
  Template? findMarkdownTemplate(ParentNode parent, String path) {
    path = path.toLowerCase();
    DocumentationModel? model = parent.findParent<DocumentationModel>();
    if (model == null) return null;
    var templates = model.findOrderedMarkdownTemplates();
    return templates.firstWhereOrNull(
        (template) => (template.hasWebUriAndFileEndsWith(path)));
  }

  static final FluentRegex filePath =
      FluentRegex().anyCharacter(Quantity.oneOrMoreTimes()).literal('/');

  static final FluentRegex fileExtension = FluentRegex()
      .literal('.')
      .characterSet(
          CharacterSet().addLetters().addDigits(), Quantity.oneOrMoreTimes())
      .endOfLine();

  String createDefaultTitle(String path) {
    String fileName = filePath.removeFirst(path);
    String fileNameWithoutExtension = fileExtension.removeFirst(fileName);
    String title = fileNameWithoutExtension.replaceAll('-', ' ');
    return title;
  }
}

/// A [DartCodeLink] is a [Link] to a piece of Dart code.
/// You can make a link to any library members, e.g.:
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
/// You can also include the library name or the full [DartFilePath] in case a project uses same member names in different libraries, e.g.:
/// - [my_lib.dart|myConstant]
/// - [lib/my_lib.dart|myFunction]
///
/// The [DocumentationBuilder] will try to resolve these [MemberLink]s in the following order:
/// - Within the [MarkdownPage], e.g.: link it to the position of a [ImportDartDocTag]
/// - Within another [WikiMarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
/// - Link it to a [GitHubProjectCodeLink]
/// The [Link] will not be replaced when the [Link] can not be resolved
class DartCodeLink extends Link {
  DartCodeLink(ParentNode parent, String title, Uri uri)
      : super(
          parent: parent,
          title: title,
          uri: uri,
        );

  @override
  Future<void> validateUriHttpGet() {
    //no validation because url may not exist just yet.
    return Future.value();
  }
}

class DartCodeLinkRule extends InCompleteLinkRule {
  DartCodeLinkRule()
      : super(
          [TitleAttributeRule()],
          nameExpression: createNameExpression(),
        );

  @override
  Future<List<RegExpMatch>> createMatches(TextNode textNode) async =>
      await dartCodeMatches(textNode);

  /// Returns matches that can be converted to DartCodeLinks
  Future<List<RegExpMatch>> dartCodeMatches(TextNode textNode) async {
    var matches = await super.createMatches(textNode);
    List<RegExpMatch> dartCodeMatches = [];
    for (RegExpMatch match in matches) {
      String path = match.namedGroup(GroupName.name)!;
      if (createUri(textNode.parent!, path) != null) {
        dartCodeMatches.add(match);
      }
    }
    return dartCodeMatches;
  }

  @override
  Link createLinkNode(
      ParentNode parent, String path, Map<String, dynamic> attributes) {
    var defaultTitle = findDartMemberPath(path);
    String title = Link.createTitle(defaultTitle, attributes);
    Uri uri = createUri(parent, path)!;
    return DartCodeLink(parent, title, uri);
  }

  /// finds a [Template] with a sourceFilePath or destinationFilePath
  /// that ends with path, while ignoring upper or lower case.
  Uri? createUri(ParentNode parent, String path) {
    path = path.toLowerCase();
    DocumentationModel? model = parent.findParent<DocumentationModel>();
    if (model != null) {
      ImportDartDocTag? importDartDocTag =
          findTag<ImportDartDocTag>(model, path);
      if (importDartDocTag != null) {
        Uri? uri = importDartDocTag.anchor.uriToAnchor;
        if (uri != null) return uri;
      }

      ImportDartCodeTag? importDartCodeTag =
          findTag<ImportDartCodeTag>(model, path);
      if (importDartCodeTag != null) {
        Uri? uri = importDartCodeTag.anchor.uriToAnchor;
        if (uri != null) return uri;
      }

      //return a link to the dart file on GitHub if the member exists in this project
      var foundPath = model.dartCodePaths.firstWhereOrNull((dartCodePath) =>
          dartCodePath.dartFilePath.path.toLowerCase().endsWith(path));
      if (foundPath != null) {
        return GitHubProject().dartFile(foundPath.dartFilePath);
      }
    }

    ///when no match: return null otherwise almost all remaining uncompleted links will be replaced
    return null;
  }

  /// Finds tags of a given Type where the path attribute ends with a given path.
  T? findTag<T extends Tag>(DocumentationModel model, String path) {
    List<T> tags = model.findChildren<T>();
    return tags.firstWhereOrNull((tag) => tag.attributes[AttributeName.path]
        .toString()
        .trim()
        .toLowerCase()
        .endsWith(path));
  }

  String findDartMemberPath(String path) {
    try {
      DartCodePath dartCodePath = DartCodePath(path);
      return dartCodePath.dartMemberPath!.path;
    } catch (e) {
      DartMemberPath dartMemberPath = DartMemberPath(path);
      return dartMemberPath.path;
    }
  }

  static FluentRegex createNameExpression() => FluentRegex().or([
        DartMemberPath.expression.startOfLine(false).endOfLine(false),
        DartCodePath.expression.startOfLine(false).endOfLine(false)
      ]);

  bool isValidatePath(String path) {
    try {
      return findDartMemberPath(path).trim().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
