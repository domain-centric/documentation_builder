import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/util/reference.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:template_engine/template_engine.dart';

/// An [ExpressionFunction] that creates a markdown hyperlink
/// This class ensures a convention is followed so that implementations can be reused in [PathFunctions]
abstract class LinkFunction extends ExpressionFunction<MarkDownLink> {
  static const nameSuffix = 'Link';
  static const descriptionPreFix = 'Returns a markdown hyperlink of ';
  LinkFunction(
      {required String namePrefix,
      required String descriptionSuffix,
      super.parameters,
      required super.function})
      : super(
            name: '$namePrefix$nameSuffix',
            description: '$descriptionPreFix$descriptionSuffix');
}

class LinkFunctions extends FunctionGroup {
  LinkFunctions()
      : super('Link Functions', [
          ReferenceLink(),
          GitHubLink(),
          GitHubWikiLink(),
          GitHubStarsLink(),
          GitHubIssuesLink(),
          GitHubMilestonesLink(),
          GitHubReleasesLink(),
          GitHubPullRequestsLink(),
          GitHubRawLink(),
          PubDevLink(),
          PubDevChangeLogLink(),
          PubDevVersionsLink(),
          PubDevExampleLink(),
          PubDevInstallLink(),
          PubDevScoreLink(),
          PubDevLicenseLink(),
        ]);
}

class TextParameter extends Parameter<String> {
  static const String id = 'text';

  TextParameter()
      : super(
            name: id,
            description:
                'The text of the hyperlink. An appropriate text will be provided if no text is defined',
            presence: Presence.optional());
}

class SuffixParameter extends Parameter<String> {
  static const String id = 'suffix';

  SuffixParameter([Presence presence = const Presence.optional()])
      : super(
            name: id,
            description:
                'A suffix to append to the URI (e.g. path, query, fragment, etc)',
            presence: presence);
}

class ReferenceLink extends LinkFunction {
  static const refId = 'ref';
  static final factories = MarkDownLinkFactories();
  ReferenceLink()
      : super(
            namePrefix: 'reference',
            descriptionSuffix: 'Creates a uri from an address.',
            parameters: [
              Parameter(
                  name: refId,
                  description: 'The ref (reference) can be:$newLine'
                      "* a Uri to something on the internet, e.g,: 'https://www.google.com' $newLine"
                      "* a package name on pub.dev, e.g.: 'documentation_builder'$newLine"
                      "* reference to a source file, e.g.: 'example/example.md' or 'lib/src/my_library.dart'$newLine"
                      "* a reference to dart library member, e.g.: 'lib/src/my_library.dart#MyClass.myField'",
                  presence: Presence.mandatory()),
              TextParameter(),
            ],
            function: (position, renderContext, parameters) async {
              var reference = parameters[refId] as String;
              var text = parameters[TextParameter.id] as String?;
              var markdownLink = await factories.create(
                context: renderContext,
                reference: reference,
                text: text,
              );
              if (markdownLink == null) {
                throw ArgumentError(
                    "'$reference' could not be translated to an existing address on the internet",
                    ReferenceLink.refId);
              }
              return markdownLink;
            });
}

class GitHubLink extends LinkFunction {
  GitHubLink()
      : super(
          namePrefix: 'gitHub',
          descriptionSuffix: "a web page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text =
                parameters[TextParameter.id] as String? ?? LocalProject.name;
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.uri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubWikiLink extends LinkFunction {
  GitHubWikiLink()
      : super(
          namePrefix: 'gitHubWiki',
          descriptionSuffix: "a wiki page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} wiki';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.wikiUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubStarsLink extends LinkFunction {
  GitHubStarsLink()
      : super(
          namePrefix: 'gitHubStars',
          descriptionSuffix: "a stars page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} stars';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.starGazersUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubIssuesLink extends LinkFunction {
  GitHubIssuesLink()
      : super(
          namePrefix: 'gitHubIssues',
          descriptionSuffix: "an issue page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} issues';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.issuesUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubMilestonesLink extends LinkFunction {
  GitHubMilestonesLink()
      : super(
          namePrefix: 'gitHubMilestones',
          descriptionSuffix: "a milestone page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} milestones';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.milestonesUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubReleasesLink extends LinkFunction {
  GitHubReleasesLink()
      : super(
          namePrefix: 'gitHubReleases',
          descriptionSuffix: "a releases page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} releases';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.releasesUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class GitHubPullRequestsLink extends LinkFunction {
  GitHubPullRequestsLink()
      : super(
          namePrefix: 'gitHubPullRequests',
          descriptionSuffix:
              "a pull request page of your project on github.com",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} pull requests';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = gitHubProject.pullRequestsUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

/// Gets a uri to plain view of the source file.
/// e.g. if you open the [uri] and click on a markdown file in github,
/// it will show the rendered markdown file
/// You can use this link instead to see the un-rendered (source) file.

class GitHubRawLink extends LinkFunction {
  GitHubRawLink()
      : super(
          namePrefix: 'gitHubRaw',
          descriptionSuffix: "a raw code page of your project on github.com",
          parameters: [
            SuffixParameter(Presence.mandatory()),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} raw';
            var gitHubProject = GitHubProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            Uri uri = gitHubProject.rawUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevLink extends LinkFunction {
  PubDevLink()
      : super(
          namePrefix: 'pubDev',
          descriptionSuffix: "the home page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name}';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.uri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevChangeLogLink extends LinkFunction {
  PubDevChangeLogLink()
      : super(
          namePrefix: 'pubDevChangeLog',
          descriptionSuffix: "the change log page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} change log';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.changeLogUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevVersionsLink extends LinkFunction {
  PubDevVersionsLink()
      : super(
          namePrefix: 'pubDevVersions',
          descriptionSuffix: "the version page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} versions';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.versionsUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevExampleLink extends LinkFunction {
  PubDevExampleLink()
      : super(
          namePrefix: 'pubDevExample',
          descriptionSuffix: "the example page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} example';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.exampleUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevInstallLink extends LinkFunction {
  PubDevInstallLink()
      : super(
          namePrefix: 'pubDevInstall',
          descriptionSuffix: "the install page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} installation';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.installUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevScoreLink extends LinkFunction {
  PubDevScoreLink()
      : super(
          namePrefix: 'pubDevScore',
          descriptionSuffix: "the score page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} score';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.scoreUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}

class PubDevLicenseLink extends LinkFunction {
  PubDevLicenseLink()
      : super(
          namePrefix: 'pubDevLicense',
          descriptionSuffix: "the license page of your project on pub.dev",
          parameters: [
            SuffixParameter(),
            TextParameter(),
          ],
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            var text = parameters[TextParameter.id] as String? ??
                '${LocalProject.name} license';
            var pubDevProject = PubDevProject.of(renderContext);
            var suffix = parameters[SuffixParameter.id] as String?;
            var uri = pubDevProject.licenseUri.append(suffix: suffix);
            return MarkDownLink(text, uri);
          },
        );
}
