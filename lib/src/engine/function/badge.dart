import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';

final badgeFunctions = FunctionGroup('Badge Functions', [
  customBadgeFunction,
  pubPackageBadgeFunction,
  pubScoreBadgeFunction,
  allPubBadgesFunction,
  gitHubBadgeFunction,
  gitHubWikiBadgeFunction,
  gitHubStarsBadgeFunction,
  gitHubIssuesBadgeFunction,
  gitHubPullRequestsBadgeFunction,
  gitHubLicenseBadgeFunction,
  allGitHubBadgesFunction,
  allPubGitHubBadgesFunction,
]);

/// [Badge]s are images with text that inform the user on the technology used in a project and other relevant information such as links to
/// - code repository
/// - project license
/// - documentation
/// - application stores
/// - ect...
///
/// There are different types of badges. [Badge]s in [Template]s :
/// - are surrounded by square brackets: []
/// - start with a ! and a name: e.g.  [!CustomBadge &rsqb;
/// - may have attribute's after the name
///
/// e.g.: [!CustomBadge label='license' message='MIT' color='informational' link='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE' &rsqb;
/// [![GitHub License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)
class Badge {
  final String? toolTip;
  final Uri image;
  final Uri link;

  static Uri imgShieldIoUri = Uri(scheme: 'https', host: 'img.shields.io');

  Badge({this.toolTip, required this.image, required this.link});

  Badge.custom({
    this.toolTip,
    required String label,
    String? message,
    required String color,
    required this.link,
  }) : image = imgShieldIoUri.append(path: 'badge/$label-$message-$color');

  @override
  String toString() {
    String toolTipMarkDown = toolTip == null ? '' : '[$toolTip]';
    return "[!$toolTipMarkDown($image)]($link)";
  }
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] toolTip.
class ToolTipParameter extends Parameter<String> {
  static const id = 'toolTip';

  ToolTipParameter(Presence presence)
    : super(
        name: id,
        description: 'This text becomes visible when hoovering over a badge',
        presence: presence,
      );
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] label.
class LabelParameter extends Parameter<String> {
  static const id = 'label';

  LabelParameter(Presence presence)
    : super(
        name: id,
        description:
            'The label is the left text of the badge '
            'and is often lower case text',
        presence: presence,
      );
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] message.
class MessageParameter extends Parameter<String> {
  static const id = 'message';

  MessageParameter(Presence presence)
    : super(
        name: id,
        description:
            'The label is the left message is the right '
            'text of the badge and can have a fill color',
        presence: presence,
      );
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] color.
class ColorParameter extends Parameter<String> {
  static const id = 'color';

  ColorParameter(Presence presence)
    : super(
        name: id,
        description:
            'The message is the right text of the [Badge] and can have fill color.'
            'The color can be defined in different ways:'
            'As color name:'
            '- brightgreen'
            '- green'
            '- yellowgreen'
            '- yellow'
            '- orange'
            '- red'
            '- blue'
            '- lightgrey'
            '- blueviolet'
            'As name'
            '- success'
            '- important'
            '- critical'
            '- informational (=default)'
            '- inactive'
            'As code:'
            '- ff69b4'
            '- 9cf',
        presence: presence,
      );
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] link.
class LinkParameter extends Parameter<String> {
  static const id = 'link';

  LinkParameter(Presence presence)
    : super(
        name: id,
        description: 'A Uri that points to a web site page.',
        presence: presence,
      );
}

/// A [FunctionDefinition]-[Parameter] for the [Badge] license type.
class LicenseTypeParameter extends Parameter<String> {
  static const id = 'licenseType';

  LicenseTypeParameter(Presence presence)
    : super(
        name: id,
        description:
            'The license type to display on the badge, e.g MIT, GNU or 3BSD',
        presence: presence,
      );
}

/// A [FunctionDefinition] that creates a customizable badge image in markdown format.
final customBadgeFunction = FunctionDefinition<String>(
  name: 'customBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a customizable badge image',
    examples: [
      ExpressionBlockExample(
        (delimiter) =>
            "${delimiter.start}customBadge(toolTip='GitHub License', label='license', message='MIT', link='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE')${delimiter.end}",
        shouldRender: "[![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(PresenceOptional()),
    LabelParameter(PresenceMandatory()),
    MessageParameter(PresenceMandatory()),
    ColorParameter(PresenceOptionalWithDefaultValue('informational')),
    LinkParameter(PresenceMandatory()),
  ],
  function: (context) async => Badge.custom(
    toolTip: context.argumentValues[ToolTipParameter.id] as String?,
    label: context.argumentValues[LabelParameter.id] as String,
    message: context.argumentValues[MessageParameter.id] as String,
    color: context.argumentValues[ColorParameter.id] as String,
    link: Uri.parse(context.argumentValues[LinkParameter.id] as String),
  ).toString(),
);

final pubPackageBadgeFunction = FunctionDefinition<String>(
  name: 'pubPackageBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge of an existing Dart or Flutter package on pub.dev',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}pubPackageBadge()${delimiter.end}",
        shouldRender: "[![Pub Package](https://img.shields.io/pub/v/documentation_builder)](https://pub.dev/packages/documentation_builder)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(PresenceOptionalWithDefaultValue('Pub Package')),
  ],
  function: (context) async {
    final uri = PubDevProject.of(context.renderContext).uri;
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(path: 'pub/v/${LocalProject.name}'),
      link: uri,
    ).toString();
  },
);

final pubScoreBadgeFunction = FunctionDefinition<String>(
  name: 'pubScoreBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge of the scores on pub.dev',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}pubScoreBadge()${delimiter.end}",
        shouldRender: "[![Pub Scores](https://img.shields.io/pub/likes/documentation_builder)](https://pub.dev/packages/documentation_builder/score)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(PresenceOptionalWithDefaultValue('Pub Scores')),
  ],
  function: (context) async {
    final pubDevProject = PubDevProject.of(context.renderContext);
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(
        path: 'pub/likes/${pubDevProject.packageName}',
      ),
      link: pubDevProject.scoreUri,
    ).toString();
  },
);

final allPubBadgesFunction = FunctionDefinition<String>(
  name: 'allPubBadges',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for all pub.dev badges',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}allPubBadges()${delimiter.end}",
        shouldRender: "[![Pub Package](https://img.shields.io/pub/v/documentation_builder)](https://pub.dev/packages/documentation_builder)\n[![Pub Scores](https://img.shields.io/pub/likes/documentation_builder)](https://pub.dev/packages/documentation_builder/score)",
      ),
    ],
  ),
  parameters: const [],
  function: (context) async => _createStringForBadges(context, [
    pubPackageBadgeFunction,
    pubScoreBadgeFunction,
  ]),
);

final gitHubBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge of a project on github.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}gitHubBadge()${delimiter.end}",
        shouldRender: "[![Project on github.com](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/documentation_builder)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(PresenceOptionalWithDefaultValue('Project on github.com')),
  ],
  function: (context) async => Badge(
    toolTip: context.argumentValues[ToolTipParameter.id] as String?,
    image: Badge.imgShieldIoUri.append(
      path: 'badge/repository-git%20hub-informational',
    ),
    link: GitHubProject.of(context.renderContext).uri,
  ).toString(),
);

final gitHubWikiBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubWikiBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge of the Wiki pages of a project on GitHub.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}gitHubWikiBadge()${delimiter.end}",
        shouldRender: "[![Project Wiki pages on github.com](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/documentation_builder/wiki)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(
      PresenceOptionalWithDefaultValue('Project Wiki pages on github.com'),
    ),
  ],
  function: (context) async => Badge(
    toolTip: context.argumentValues[ToolTipParameter.id] as String?,
    image: Badge.imgShieldIoUri.append(
      path: 'badge/documentation-wiki-informational',
    ),
    link: GitHubProject.of(context.renderContext).wikiUri,
  ).toString(),
);

final gitHubStarsBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubStarsBadge',
  documentation: FunctionDefinitionDocumentation(
    description:
        'Creates markdown for a badge with the amount of stars on github.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}gitHubStarsBadge()${delimiter.end}",
        shouldRender: "[![Stars ranking on github.com](https://img.shields.io/github/stars/domain-centric/documentation_builder?style=flat)](https://github.com/domain-centric/documentation_builder/stargazers)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(
      PresenceOptionalWithDefaultValue('Stars ranking on github.com'),
    ),
  ],
  function: (context) async {
    final gitHubProject = GitHubProject.of(context.renderContext);
    final projectPath = gitHubProject.uri.pathSegments.join('/');
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(
        path: 'github/stars/$projectPath',
        query: {'style': 'flat'},
      ),
      link: gitHubProject.starGazersUri,
    ).toString();
  },
);

final gitHubIssuesBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubIssuesBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge with the amount of open issues on github.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}gitHubIssuesBadge()${delimiter.end}",
        shouldRender: "[![Open issues on github.com](https://img.shields.io/github/issues/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/issues)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(
      PresenceOptionalWithDefaultValue('Open issues on github.com'),
    ),
  ],
  function: (context) async {
    final gitHubProject = GitHubProject.of(context.renderContext);
    final projectPath = gitHubProject.uri.pathSegments.join('/');
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(path: 'github/issues/$projectPath'),
      link: gitHubProject.issuesUri,
    ).toString();
  },
);

final gitHubPullRequestsBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubPullRequestsBadge',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for a badge with the amount of open pull requests on github.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) =>
            "${delimiter.start}gitHubPullRequestsBadge()${delimiter.end}",
        shouldRender: "[![Open pull requests on github.com](https://img.shields.io/github/issues-pr/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/pulls)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(
      PresenceOptionalWithDefaultValue('Open pull requests on github.com'),
    ),
  ],
  function: (context) async {
    final gitHubProject = GitHubProject.of(context.renderContext);
    final projectPath = gitHubProject.uri.pathSegments.join('/');
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(path: 'github/issues-pr/$projectPath'),
      link: gitHubProject.pullRequestsUri,
    ).toString();
  },
);

final gitHubLicenseBadgeFunction = FunctionDefinition<String>(
  name: 'gitHubLicenseBadge',
  documentation: FunctionDefinitionDocumentation(
    description:
        'Creates markdown for a badge with the project license on github.com',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}gitHubLicenseBadge()${delimiter.end}",
        shouldRender: "[![Project License](https://img.shields.io/github/license/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
      ),
    ],
  ),
  parameters: [
    ToolTipParameter(PresenceOptionalWithDefaultValue('Project License')),
  ],
  function: (context) async {
    final gitHubProject = GitHubProject.of(context.renderContext);
    final projectPath = gitHubProject.uri.pathSegments.join('/');
    return Badge(
      toolTip: context.argumentValues[ToolTipParameter.id] as String?,
      image: Badge.imgShieldIoUri.append(path: 'github/license/$projectPath'),
      link: gitHubProject.licenseUri(),
    ).toString();
  },
);

final allGitHubBadgesFunction = FunctionDefinition<String>(
  name: 'allGitHubBadges',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for all github.com badges',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}allGitHubBadges()${delimiter.end}",
        shouldRender: "[![Project on github.com](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/documentation_builder)\n[![Project Wiki pages on github.com](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/documentation_builder/wiki)\n[![Stars ranking on github.com](https://img.shields.io/github/stars/domain-centric/documentation_builder?style=flat)](https://github.com/domain-centric/documentation_builder/stargazers)\n[![Open issues on github.com](https://img.shields.io/github/issues/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/issues)\n[![Open pull requests on github.com](https://img.shields.io/github/issues-pr/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/pulls)\n[![Project License](https://img.shields.io/github/license/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
      ),
    ],
  ),
  parameters: const [],
  function: (context) async => _createStringForBadges(context, [
    gitHubBadgeFunction,
    gitHubWikiBadgeFunction,
    gitHubStarsBadgeFunction,
    gitHubIssuesBadgeFunction,
    gitHubPullRequestsBadgeFunction,
    gitHubLicenseBadgeFunction,
  ]),
);

final allPubGitHubBadgesFunction = FunctionDefinition<String>(
  name: 'allPubGitHubBadges',
  documentation: FunctionDefinitionDocumentation(
    description: 'Creates markdown for all pub.dev and github.com badges',
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}allPubGitHubBadges()${delimiter.end}",
        shouldRender: "[![Pub Package](https://img.shields.io/pub/v/documentation_builder)](https://pub.dev/packages/documentation_builder)\n[![Project on github.com](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/documentation_builder)\n[![Project Wiki pages on github.com](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/documentation_builder/wiki)\n[![Pub Scores](https://img.shields.io/pub/likes/documentation_builder)](https://pub.dev/packages/documentation_builder/score)\n[![Stars ranking on github.com](https://img.shields.io/github/stars/domain-centric/documentation_builder?style=flat)](https://github.com/domain-centric/documentation_builder/stargazers)\n[![Open issues on github.com](https://img.shields.io/github/issues/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/issues)\n[![Open pull requests on github.com](https://img.shields.io/github/issues-pr/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/pulls)\n[![Project License](https://img.shields.io/github/license/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
      ),
    ],
  ),
  parameters: const [],
  function: (context) async => _createStringForBadges(context, [
    pubPackageBadgeFunction,
    gitHubBadgeFunction,
    gitHubWikiBadgeFunction,
    pubScoreBadgeFunction,
    gitHubStarsBadgeFunction,
    gitHubIssuesBadgeFunction,
    gitHubPullRequestsBadgeFunction,
    gitHubLicenseBadgeFunction,
  ]),
);

Future<String> _createStringForBadges(
  FunctionCallContext context,
  List<FunctionDefinition<String>> badgeFunctions,
) async {
  final badgeResults = await Future.wait(
    badgeFunctions.map((badgeFunction) async {
      final parameterValues = <String, dynamic>{};
      for (final parameter in badgeFunction.parameters) {
        final presence = parameter.presence;
        if (presence is PresenceOptionalWithDefaultValue) {
          parameterValues[parameter.name] = presence.defaultValue;
        }
      }
      final callContext = FunctionCallContext(
        context.functionLocation,
        context.renderContext,
        const {},
        parameterValues,
      );
      return (await badgeFunction.function(callContext)).toString();
    }),
  );
  return badgeResults.join(newLine);
}
