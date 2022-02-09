import 'package:documentation_builder/src/parser/badge_parser.dart';
import 'package:documentation_builder/src/parser/parser.dart';
import 'package:documentation_builder/src/project/github_project.dart';
import 'package:documentation_builder/src/project/local_project.dart';
import 'package:documentation_builder/src/project/pub_dev_project.dart';
import 'package:test/test.dart';

const green = 'green';
const toolTip = 'tooltip';
const label = 'label';
const message = 'message';
const defaultColor = 'informational';
final uri = Uri.parse('https://www.google.com');

main() {
  group('CustomBadge', () {
    group('class: CustomBadge', () {
      group('method: toString', () {
        test("without tooltip and color", () {
          var badge = CustomBadge(
            label: label,
            message: message,
            link: uri,
          );
          expect(badge.toString(),
              '[!(https://img.shields.io/badge/$label-$message-$defaultColor)]($uri)');
        });
        test("without tooltip", () {
          var badge = CustomBadge(
            label: 'label',
            message: 'message',
            color: 'green',
            link: Uri.parse('https://www.google.com'),
          );
          expect(badge.toString(),
              '[!(https://img.shields.io/badge/$label-$message-$green)]($uri)');
        });
        test("without color", () {
          var badge = CustomBadge(
            toolTip: toolTip,
            label: 'label',
            message: 'message',
            link: Uri.parse('https://www.google.com'),
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/badge/$label-$message-$defaultColor)]($uri)');
        });
      });
    });

    group('class: CustomBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = CustomBadgeRule();
          expect(
              rule.expression.hasMatch(
                  "[!custombadge $label='$label' $message='$message' $uri='$uri']"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = CustomBadgeRule();
          expect(
              rule.expression.hasMatch(
                  "[!CustomBadge $label='$label' $message='$message' $uri='$uri']"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = CustomBadgeRule();
          expect(
              rule.expression.hasMatch(
                  "[ ! CustomBadge   $label='$label'  $message='$message'    link='$uri'    ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: CustomBadge', () {
        test('with tooltip, label, message, color, link attributes', () async {
          var parsedNode = await BadgeParser().parse(TestRootNode(
              "[!CustomBadge $toolTip='$toolTip' $label='$label' $message='$message' color='$green' link='$uri' ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is CustomBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/badge/$label-$message-$green)]($uri)');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode = await BadgeParser().parse(TestRootNode(
              "[!CustomBadge $label='$label' $message='$message' color='$green' link='$uri' ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is CustomBadge, true);
          expect(parsedNode.children.first.toString(),
              '[!(https://img.shields.io/badge/$label-$message-$green)]($uri)');
        });

        test('missing required label attribute', () {
          var text =
              "[!CustomBadge $toolTip='$toolTip' $message='$message' color='$green' link='$uri' ]";
          expect(
              () async => await BadgeParser().parse(TestRootNode(text)),
              throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
                  'toString()',
                  equals(
                      "Required label attribute is missing in badge: '$text'."))));
        });

        test('invalid attribute', () {
          var text =
              "[!CustomBadge $toolTip='$toolTip' $message='$message' 123 color='$green' link='$uri' ]";
          expect(
              () => BadgeParser().parse(TestRootNode(text)),
              throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
                  'toString()',
                  equals(
                      "'123' could not be parsed to an attribute in badge: '$text'."))));
        });
      });
    });
  });

  group('PubPackageBadge', () {
    group('class: PubPackageBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = PubPackageBadge();
          expect(badge.toString(),
              '[![Pub Package](https://img.shields.io/pub/v/${LocalProject.name})](${PubDevProject().uri})');
        });
        test("without tooltip", () {
          var badge = PubPackageBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/pub/v/${LocalProject.name})](${PubDevProject().uri})');
        });
      });
    });

    group('class: PubPackageBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = PubPackageBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!pubpackagebadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = PubPackageBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!PubPackageBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = PubPackageBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[ ! PubPackageBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: PubPackageBadge', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser()
              .parse(TestRootNode("[!PubPackageBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is PubPackageBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/pub/v/${LocalProject.name})](${PubDevProject().uri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode =
              await BadgeParser().parse(TestRootNode("[!PubPackageBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is PubPackageBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![Pub Package](https://img.shields.io/pub/v/${LocalProject.name})](${PubDevProject().uri})');
        });
      });
    });
  });

  group('GitHubBadge', () {
    group('class: GitHubBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = GitHubBadge();
          expect(badge.toString(),
              '[![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](${GitHubProject().uri})');
        });
        test("without tooltip", () {
          var badge = GitHubBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/badge/repository-git%20hub-informational)](${GitHubProject().uri})');
        });
      });
    });

    group('class: GitHubBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = GitHubBadgeRule();
          expect(
              rule.expression.hasMatch("[!githubbadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = GitHubBadgeRule();
          expect(
              rule.expression.hasMatch("[!GitHubBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = GitHubBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[ ! GitHubBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: GitHubBadgeRule', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser()
              .parse(TestRootNode("[!GitHubBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/badge/repository-git%20hub-informational)](${GitHubProject().uri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode =
              await BadgeParser().parse(TestRootNode("[!GitHubBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](${GitHubProject().uri})');
        });
      });
    });
  });

  group('GitHubWikiBadge', () {
    group('class: GitHubWikiBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = GitHubWikiBadge();
          expect(badge.toString(),
              '[![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](${GitHubProject().wikiUri})');
        });
        test("without tooltip", () {
          var badge = GitHubWikiBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/badge/documentation-wiki-informational)](${GitHubProject().wikiUri})');
        });
      });
    });

    group('class: GitHubWikiBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = GitHubWikiBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!githubwikibadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = GitHubWikiBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!GitHubWikiBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = GitHubWikiBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[ ! GitHubWikiBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: GitHubWikiBadge', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser()
              .parse(TestRootNode("[!GitHubWikiBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubWikiBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/badge/documentation-wiki-informational)](${GitHubProject().wikiUri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode =
              await BadgeParser().parse(TestRootNode("[!GitHubWikiBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubWikiBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](${GitHubProject().wikiUri})');
        });
      });
    });
  });

  group('GitHubStarsBadge', () {
    group('class: GitHubStarsBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = GitHubStarsBadge();
          expect(badge.toString(),
              '[![GitHub Stars](https://img.shields.io/github/stars${GitHubProject().uri!.path})](${GitHubProject().stargazersUri})');
        });
        test("without tooltip", () {
          var badge = GitHubStarsBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/github/stars${GitHubProject().uri!.path})](${GitHubProject().stargazersUri})');
        });
      });
    });

    group('class: GitHubStarsBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = GitHubStarsBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!githubstarsbadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = GitHubStarsBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!GitHubStarsBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = GitHubStarsBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[ ! GitHubStarsBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: GitHubStarsBadge', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser()
              .parse(TestRootNode("[!GitHubStarsBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubStarsBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/github/stars${GitHubProject().uri!.path})](${GitHubProject().stargazersUri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode =
              await BadgeParser().parse(TestRootNode("[!GitHubStarsBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubStarsBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![GitHub Stars](https://img.shields.io/github/stars${GitHubProject().uri!.path})](${GitHubProject().stargazersUri})');
        });
      });
    });
  });

  group('GitHubIssuesBadge', () {
    group('class: GitHubIssuesBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = GitHubIssuesBadge();
          expect(badge.toString(),
              '[![GitHub Issues](https://img.shields.io/github/issues${GitHubProject().uri!.path})](${GitHubProject().issuesUri})');
        });
        test("without tooltip", () {
          var badge = GitHubIssuesBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/github/issues${GitHubProject().uri!.path})](${GitHubProject().issuesUri})');
        });
      });
    });

    group('class: GitHubIssuesBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = GitHubIssuesBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!githubissuesbadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = GitHubIssuesBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!GitHubIssuesBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = GitHubIssuesBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[ ! GitHubIssuesBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: GitHubIssuesBadge', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser().parse(
              TestRootNode("[!GitHubIssuesBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubIssuesBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/github/issues${GitHubProject().uri!.path})](${GitHubProject().issuesUri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode =
              await BadgeParser().parse(TestRootNode("[!GitHubIssuesBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubIssuesBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![GitHub Issues](https://img.shields.io/github/issues${GitHubProject().uri!.path})](${GitHubProject().issuesUri})');
        });
      });
    });
  });

  group('GitHubPullRequestsBadge', () {
    group('class: GitHubPullRequestsBadge ', () {
      group('method: toString', () {
        test("without tooltip", () {
          var badge = GitHubPullRequestsBadge();
          expect(badge.toString(),
              '[![GitHub Pull Requests](https://img.shields.io/github/issues-pr${GitHubProject().uri!.path})](${GitHubProject().pullRequestsUri})');
        });
        test("without tooltip", () {
          var badge = GitHubPullRequestsBadge(
            toolTip: toolTip,
          );
          expect(badge.toString(),
              '[![$toolTip](https://img.shields.io/github/issues-pr${GitHubProject().uri!.path})](${GitHubProject().pullRequestsUri})');
        });
      });
    });

    group('class: GitHubPullRequestsBadgeRule', () {
      group('field: expression', () {
        test("lowercase badge name has match", () {
          var rule = GitHubPullRequestsBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!githubpullrequestsbadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name has match", () {
          var rule = GitHubPullRequestsBadgeRule();
          expect(
              rule.expression
                  .hasMatch("[!GitHubPullRequestsBadge $toolTip='$toolTip' ]"),
              true);
        });
        test("lowercase and uppercase badge name with spaces has match", () {
          var rule = GitHubPullRequestsBadgeRule();
          expect(
              rule.expression.hasMatch(
                  "[ ! GitHubPullRequestsBadge   $toolTip='$toolTip'   ]"),
              true);
        });
      });
    });

    group('class: BadgeParser', () {
      group('class: GitHubPullRequestsBadge', () {
        test('with tooltip', () async {
          var parsedNode = await BadgeParser().parse(
              TestRootNode("[!GitHubPullRequestsBadge $toolTip='$toolTip'  ]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubPullRequestsBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![$toolTip](https://img.shields.io/github/issues-pr${GitHubProject().uri!.path})](${GitHubProject().pullRequestsUri})');
        });

        test('missing optional attribute tooltip', () async {
          var parsedNode = await BadgeParser()
              .parse(TestRootNode("[!GitHubPullRequestsBadge]"));

          expect(parsedNode.children.length, 1);
          expect(parsedNode.children.first is GitHubPullRequestsBadge, true);
          expect(parsedNode.children.first.toString(),
              '[![GitHub Pull Requests](https://img.shields.io/github/issues-pr${GitHubProject().uri!.path})](${GitHubProject().pullRequestsUri})');
        });
      });
    });
  });
}

class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}
