import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:template_engine/template_engine.dart';

class BadgeFunctions extends FunctionGroup {
  BadgeFunctions()
    : super('Badge Functions', [
        CustomBadge(),
        PubPackageBadge(),
        PubScoreBadge(),
        AllPubBadges(),
        GitHubBadge(),
        GitHubWikiBadge(),
        GitHubStarsBadge(),
        GitHubIssuesBadge(),
        GitHubPullRequestsBadge(),
        GitHubLicenseBadge(),
        AllGitHubBadges(),
        AllPubGitHubBadges(),
      ]);
}

/// [Badge]s are images with text that inform the user on the technology used in a project and other relevant information such as links to
/// - code repository
/// - project license
/// - documentation
/// - application stores
/// - ect...
///
/// There are different types of badges. [Badge]s in [TemplateFile]s :
/// - are surrounded by square brackets: []
/// - start with a ! and a name: e.g.  [!CustomBadge &rsqb;
/// - may have [Attribute]s after the name
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

class ToolTipParameter extends Parameter<String> {
  static const id = 'toolTip';
  ToolTipParameter(Presence presence)
    : super(
        name: id,
        description: 'This text becomes visible when hoovering over a badge',
        presence: presence,
      );
}

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

class ColorParameter extends Parameter<String> {
  static const id = 'color';
  ColorParameter(Presence presence)
    : super(
        name: id,
        description:
            'The message is the right text of the [Badge] and can have fill color.$newLine'
            'The color can be defined in different ways:$newLine'
            'As color name:$newLine'
            '- brightgreen$newLine'
            '- green$newLine'
            '- yellowgreen$newLine'
            '- yellow$newLine'
            '- orange$newLine'
            '- red$newLine'
            '- blue$newLine'
            '- lightgrey$newLine'
            '- blueviolet$newLine'
            'As name$newLine'
            '- success$newLine'
            '- important$newLine'
            '- critical$newLine'
            '- informational (=default)$newLine'
            '- inactive$newLine'
            'As code:$newLine'
            '- ff69b4$newLine'
            '- 9cf$newLine',
        presence: presence,
      );
}

class LinkParameter extends Parameter<String> {
  static const id = 'link';
  LinkParameter(Presence presence)
    : super(
        name: id,
        description: 'A Uri that points to a web site page.',
        presence: presence,
      );
}

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

class CustomBadge extends ExpressionFunction<String> {
  CustomBadge()
    : super(
        name: 'customBadge',
        description: 'Creates markdown for a customizable badge image',
        parameters: [
          ToolTipParameter(Presence.optional()),
          LabelParameter(Presence.mandatory()),
          MessageParameter(Presence.mandatory()),
          ColorParameter(Presence.optionalWithDefaultValue('informational')),
          LinkParameter(Presence.mandatory()),
        ],
        exampleExpression:
            "{{customBadge(tooltip='GitHub License' label='license' message='MIT' link='https://github.com/domain-centric/documentation_builder/blob/main/LICENSE')}}",
        exampleResult:
            "[![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async =>
                Badge.custom(
                  toolTip: parameterValues[ToolTipParameter.id] as String?,
                  label: parameterValues[LabelParameter.id] as String,
                  message: parameterValues[MessageParameter.id] as String,
                  color: parameterValues[MessageParameter.id] as String,
                  link: Uri.parse(
                    (parameterValues[LinkParameter.id] as String),
                  ),
                ).toString(),
      );
}

class PubPackageBadge extends ExpressionFunction<String> {
  PubPackageBadge()
    : super(
        name: 'pubPackageBadge',
        parameters: [
          ToolTipParameter(Presence.optionalWithDefaultValue('Pub Package')),
        ],
        description:
            'Creates markdown for a badge of an existing Dart or Flutter package on pub.dev',
        exampleResult:
            "[![Pub Package](https://img.shields.io/pub/v/documentation_builder)](https://pub.dev/packages/documentation_builder)",
        function: (
          String position,
          RenderContext renderContext,
          Map<String, Object> parameterValues,
        ) async {
          var uri = PubDevProject.of(renderContext).uri;
          return Badge(
            toolTip: parameterValues[ToolTipParameter.id] as String,
            image: Badge.imgShieldIoUri.append(
              path: 'pub/v/${LocalProject.name}',
            ),
            link: uri,
          ).toString();
        },
      );
}

class PubScoreBadge extends ExpressionFunction<String> {
  PubScoreBadge()
    : super(
        name: 'pubScoresBadge',
        parameters: [
          ToolTipParameter(Presence.optionalWithDefaultValue('Pub Scores')),
        ],
        description: 'Creates markdown for a badge of the scores on pub.dev',
        exampleResult:
            "[![Pub Scores](https://img.shields.io/pub/likes/documentation_builder)",
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async =>
                Badge(
                  toolTip: parameterValues[ToolTipParameter.id] as String,
                  image: Badge.imgShieldIoUri.append(
                    path: 'pub/likes/${LocalProject.name}',
                  ),
                  link: PubDevProject.of(renderContext).scoreUri,
                ).toString(),
      );
}

class AllPubBadges extends ExpressionFunction {
  AllPubBadges()
    : super(
        name: 'allPubBadges',
        description: 'Creates markdown for all pub.dev badges',
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async => await _createStringForBadges(position, renderContext, [
              PubPackageBadge(),
              PubScoreBadge(),
            ]),
      );
}

class GitHubBadge extends ExpressionFunction {
  GitHubBadge()
    : super(
        name: 'gitHubBadge',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue('Project on github.com'),
          ),
        ],
        description: 'Creates markdown for a badge of a project on github.com',
        exampleResult:
            "[![Project on github.com](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/domain-centric/documentation_builder)",
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async =>
                Badge(
                  toolTip: parameterValues[ToolTipParameter.id] as String,
                  image: Badge.imgShieldIoUri.append(
                    path: 'badge/repository-git%20hub-informational',
                  ),
                  link: GitHubProject.of(renderContext).uri,
                ).toString(),
      );
}

class GitHubWikiBadge extends ExpressionFunction {
  GitHubWikiBadge()
    : super(
        name: 'gitHubWikiBadge',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue(
              'Project Wiki pages on github.com',
            ),
          ),
        ],
        description:
            'Creates markdown for a badge of the Wiki pages of a project on GitHub.com',
        exampleResult:
            "[![Project Wiki pages on github.com](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/domain-centric/documentation_builder/wiki)",
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async =>
                Badge(
                  toolTip: parameterValues[ToolTipParameter.id] as String,
                  image: Badge.imgShieldIoUri.replace(
                    path: 'badge/documentation-wiki-informational',
                  ),
                  link: GitHubProject.of(renderContext).wikiUri,
                ).toString(),
      );
}

class GitHubStarsBadge extends ExpressionFunction {
  GitHubStarsBadge()
    : super(
        name: 'gitHubStarsBadge',
        description:
            'Creates markdown for a badge with the amount of stars on github.com',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue('Stars ranking on github.com'),
          ),
        ],
        exampleResult:
            "[![Stars ranking on github.com](https://img.shields.io/github/stars/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/stargazers)",
        function: (
          String position,
          RenderContext renderContext,
          Map<String, Object> parameterValues,
        ) async {
          var gitHubProject = GitHubProject.of(renderContext);
          return Badge(
            toolTip: parameterValues[ToolTipParameter.id] as String,
            image: Badge.imgShieldIoUri.append(
              path: 'github/stars${gitHubProject.uri.path}',
            ),
            link: gitHubProject.starGazersUri,
          ).toString();
        },
      );
}

class GitHubIssuesBadge extends ExpressionFunction {
  GitHubIssuesBadge()
    : super(
        name: 'gitHubIssuesBadge',
        description:
            'Creates markdown for a badge with the amount of open issues on github.com',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue('Open issues on github.com'),
          ),
        ],
        exampleResult:
            "[![Open issues on github.com](https://img.shields.io/github/issues/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/issues)",
        function: (
          String position,
          RenderContext renderContext,
          Map<String, Object> parameterValues,
        ) async {
          var gitHubProject = GitHubProject.of(renderContext);
          return Badge(
            toolTip: parameterValues[ToolTipParameter.id] as String,
            image: Badge.imgShieldIoUri.append(
              path: 'github/issues${gitHubProject.uri.path}',
            ),
            link: gitHubProject.issuesUri,
          ).toString();
        },
      );
}

class GitHubPullRequestsBadge extends ExpressionFunction {
  GitHubPullRequestsBadge()
    : super(
        name: 'gitHubPullRequestsBadge',
        description:
            'Creates markdown for a badge with the amount of open pull requests on github.com',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue(
              'Open pull requests on github.com',
            ),
          ),
        ],
        exampleResult:
            "[![Open pull requests on github.com](https://img.shields.io/github/issues-pr/domain-centric/documentation_builder)](https://github.com/domain-centric/documentation_builder/pull)",
        function: (
          String position,
          RenderContext renderContext,
          Map<String, Object> parameterValues,
        ) async {
          var gitHubProject = GitHubProject.of(renderContext);
          return Badge(
            toolTip: parameterValues[ToolTipParameter.id] as String,
            image: Badge.imgShieldIoUri.append(
              path: 'github/issues-pr${gitHubProject.uri.path}',
            ),
            link: gitHubProject.pullRequestsUri,
          ).toString();
        },
      );
}

class GitHubLicenseBadge extends ExpressionFunction {
  GitHubLicenseBadge()
    : super(
        name: 'gitHubLicenseBadge',
        description:
            'Creates markdown for a badge with the amount of open pull requests on github.com',
        parameters: [
          ToolTipParameter(
            Presence.optionalWithDefaultValue('Project License'),
          ),
        ],
        exampleResult:
            "[![Project License](https://img.shields.io/github/license/domain-centric/documentation_buider)](https://github.com/domain-centric/documentation_builder/blob/main/LICENSE)",
        function: (
          String position,
          RenderContext renderContext,
          Map<String, Object> parameterValues,
        ) async {
          var gitHubProject = GitHubProject.of(renderContext);
          var licenseText = gitHubProject.localLicense;
          if (licenseText != null) {
            return Badge.custom(
              toolTip: parameterValues[ToolTipParameter.id] as String,
              label: 'license',
              message: licenseText.licenseType,
              color: 'blue',
              link: gitHubProject.licenseUri(),
            ).toString();
          }

          return Badge(
            toolTip: parameterValues[ToolTipParameter.id] as String,
            image: Badge.imgShieldIoUri.append(
              path: 'github/license${gitHubProject.uri.path}',
            ),
            link: gitHubProject.licenseUri(),
          ).toString();
        },
      );
}

class AllGitHubBadges extends ExpressionFunction {
  AllGitHubBadges()
    : super(
        name: 'allGitHubBadges',
        description: 'Creates markdown for all github.com badges',
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async => await _createStringForBadges(position, renderContext, [
              GitHubBadge(),
              GitHubWikiBadge(),
              GitHubStarsBadge(),
              GitHubIssuesBadge(),
              GitHubPullRequestsBadge(),
              GitHubLicenseBadge(),
            ]),
      );
}

class AllPubGitHubBadges extends ExpressionFunction {
  AllPubGitHubBadges()
    : super(
        name: 'allPubGitHubBadges',
        description: 'Creates markdown for all pub.dev and github.com badges',
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async => await _createStringForBadges(position, renderContext, [
              PubPackageBadge(),
              GitHubBadge(),
              GitHubWikiBadge(),
              PubScoreBadge(),
              GitHubStarsBadge(),
              GitHubIssuesBadge(),
              GitHubPullRequestsBadge(),
              GitHubLicenseBadge(),
            ]),
      );
}

Future<String> _createStringForBadges(
  String position,
  RenderContext renderContext,
  List<ExpressionFunction> badgeFunctions,
) async {
  var badgeResults = await Future.wait(
    badgeFunctions.map((b) async {
      var parametersWithOptionalValues = b.parameters.where(
        (p) => p.presence.optionalWithDefaultValue,
      );
      var parameterValues = <String, Object>{
        for (var p in parametersWithOptionalValues)
          p.name: p.presence.defaultValue as Object,
      };
      return (await b.function(
        position,
        renderContext,
        parameterValues,
      )).toString();
    }),
  );
  return badgeResults.join(newLine);
}
