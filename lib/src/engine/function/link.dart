import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/util/reference.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:template_engine/template_engine.dart';

final _factories = MarkDownLinkFactories();

/// A [FunctionGroup] of functions that create markdown hyperlinks.
final linkFunctions = FunctionGroup('Link Functions', [
  referenceLinkFunction,
  gitHubLinkFunction,
  gitHubWikiLinkFunction,
  gitHubStarsLinkFunction,
  gitHubIssuesLinkFunction,
  gitHubMilestonesLinkFunction,
  gitHubReleasesLinkFunction,
  gitHubPullRequestsLinkFunction,
  gitHubRawLinkFunction,
  pubDevLinkFunction,
  pubDevChangeLogLinkFunction,
  pubDevVersionsLinkFunction,
  pubDevExampleLinkFunction,
  pubDevInstallLinkFunction,
  pubDevScoreLinkFunction,
  pubDevLicenseLinkFunction,
]);

class LinkFunctionArgumentName {
  static const ref = 'ref';
}

/// An [FunctionDefinition] that creates a markdown hyperlink
/// Base for [linkFunctions] and [pathFunctions].
class LinkFunctionDefinition extends FunctionDefinition<MarkDownLink> {
  static const nameSuffix = 'Link';
  static const descriptionPreFix = 'Returns a markdown hyperlink of ';
  final String namePrefix;
  final String descriptionSuffix;

  LinkFunctionDefinition({
    required this.namePrefix,
    required this.descriptionSuffix,
    super.parameters,
    required super.function,
  }) : super(
         name: '$namePrefix$nameSuffix',
         documentation: FunctionDefinitionDocumentation(
           description: descriptionSuffix,
           examples: [],
         ),
       );
}

/// A [Parameter] that represents the text of a hyperlink.
class TextParameter extends Parameter<String> {
  static const String id = 'text';

  TextParameter()
    : super(
        name: id,
        description: 'The text of the hyperlink. An appropriate text will be provided if no text is defined',
        presence: PresenceOptional(),
      );
}

/// A [Parameter] that represents a suffix to append to the URI.
class SuffixParameter extends Parameter<String> {
  static const String id = 'suffix';

  SuffixParameter([Presence? presence])
    : super(
        name: id,
        description:
            'A suffix to append to the URI (e.g. path, query, fragment, etc)',
        presence: presence ?? PresenceOptional(),
      );
}

/// Creates a markdown hyperlink to a reference.
final referenceLinkFunction = LinkFunctionDefinition(
  namePrefix: 'reference',
  descriptionSuffix: 'a reference uri.',

  parameters: [
    Parameter<String>(
      name: LinkFunctionArgumentName.ref,
      description:
          'The ref (reference) can be:$newLine$newLine'
          "* a Uri to something on the internet, e.g,: 'https://www.google.com' $newLine"
          "* a package name on pub.dev, e.g.: 'documentation_builder'$newLine"
          "* reference to a source file, e.g.: 'example/example.md' or 'lib/src/my_library.dart'$newLine"
          "* a reference to dart library member, e.g.: 'lib/src/my_library.dart#MyClass.myField'$newLine",
      presence: PresenceMandatory(),
    ),
    TextParameter(),
  ],
  function: (context) async {
    final reference =
        context.argumentValues[LinkFunctionArgumentName.ref] as String;
    final text = context.argumentValues[TextParameter.id] as String?;
    final markdownLink = await _factories.create(
      context: context.renderContext,
      reference: reference,
      text: text,
    );
    if (markdownLink == null) {
      throw ArgumentError(
        "'$reference' could not be translated to an existing address on the internet",
        LinkFunctionArgumentName.ref,
      );
    }
    return markdownLink;
  },
);

/// Creates a markdown hyperlink to a GitHub project page.
final gitHubLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHub',
  descriptionSuffix: 'a web page of your project on github.com',

  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        LocalProject.name;
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.uri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub wiki page.
final gitHubWikiLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubWiki',
  descriptionSuffix: 'a wiki page of your project on github.com',

  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} wiki';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.wikiUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub stars page.
final gitHubStarsLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubStars',
  descriptionSuffix: 'a stars page of your project on github.com',

  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} stars';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.starGazersUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub issues page.
final gitHubIssuesLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubIssues',
  descriptionSuffix: 'an issue page of your project on github.com',

  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} issues';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.issuesUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub milestones page.
final gitHubMilestonesLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubMilestones',
  descriptionSuffix: 'a milestone page of your project on github.com',

  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} milestones';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.milestonesUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub releases page.
final gitHubReleasesLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubReleases',
  descriptionSuffix: 'a releases page of your project on github.com',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} releases';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.releasesUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a GitHub pull requests page.
final gitHubPullRequestsLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubPullRequests',
  descriptionSuffix: 'a pull request page of your project on github.com',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} pull requests';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.pullRequestsUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Gets a URI to a plain view of the source file on GitHub.
final gitHubRawLinkFunction = LinkFunctionDefinition(
  namePrefix: 'gitHubRaw',
  descriptionSuffix: 'a raw code page of your project on github.com',
  parameters: [SuffixParameter(PresenceMandatory()), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} raw';
    final gitHubProject = GitHubProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = gitHubProject.rawUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to a pub.dev package.
final pubDevLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDev',
  descriptionSuffix: 'the home page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        LocalProject.name;
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.uri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the change log page of a pub.dev package.
final pubDevChangeLogLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevChangeLog',
  descriptionSuffix: 'the change log page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} change log';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.changeLogUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the versions page of a pub.dev package.
final pubDevVersionsLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevVersions',
  descriptionSuffix: 'the version page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} versions';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.versionsUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the example page of a pub.dev package.
final pubDevExampleLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevExample',
  descriptionSuffix: 'the example page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} example';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.exampleUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the install page of a pub.dev package.
final pubDevInstallLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevInstall',
  descriptionSuffix: 'the install page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} installation';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.installUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the score page of a pub.dev package.
final pubDevScoreLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevScore',
  descriptionSuffix: 'the score page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} score';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.scoreUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);

/// Creates a markdown hyperlink to the license page of a pub.dev package.
final pubDevLicenseLinkFunction = LinkFunctionDefinition(
  namePrefix: 'pubDevLicense',
  descriptionSuffix: 'the license page of your project on pub.dev',
  parameters: [SuffixParameter(), TextParameter()],
  function: (context) async {
    final text =
        context.argumentValues[TextParameter.id] as String? ??
        '${LocalProject.name} license';
    final pubDevProject = PubDevProject.of(context.renderContext);
    final suffix = context.argumentValues[SuffixParameter.id] as String?;
    final uri = pubDevProject.licenseUri.append(suffix: suffix);
    return MarkDownLink(text, uri);
  },
);
