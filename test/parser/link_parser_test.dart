import 'dart:io';

import 'package:documentation_builder/parser/link_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  String suffixName = UriSuffixAttributeRule().name;
  String wikiSuffixValue = 'wiki';
  String wikiSuffixAttribute = '$suffixName="$wikiSuffixValue"';
  String exampleSuffixValue = 'example';
  String exampleSuffixAttribute = '$suffixName="$exampleSuffixValue"';
  String invalidSuffixValue = 'none-existing-path-suffix';
  String invalidSuffixAttribute = '$suffixName="$invalidSuffixValue"';
  String titleName = TitleAttributeRule().name;
  String titleValue = '# Title';
  String titleAttribute = "  $titleName  : '$titleValue'  ";
  String uri = 'https://google.com';

  group('class: Link', () {
    group('constructor:', () {
      test("Correct Link", () {
        Link link = Link(parent: null, title: titleValue, uri: Uri.parse(uri));
        expect(link.title, titleValue);
        expect(link.uri, Uri.parse(uri));
        expect(link.toString(), '[$titleValue]($uri)');
      });
      test("Link without title", () {
        expect(
            () => Link(parent: null, title: '  ', uri: Uri.parse(uri)),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals('The title attribute may not be empty'),
            )));
      });
      test("Link with empty url", () {
        var emptyUri = '';
        Link link =
            Link(parent: null, title: titleValue, uri: Uri.parse(emptyUri));
        expect(link.title, titleValue);
        expect(link.uri, Uri.parse(emptyUri));
        expect(link.toString(), '[$titleValue]($emptyUri)');
        expect(
            () async => await link.validateUriHttpGet(),
            throwsA(isA<ArgumentError>().having(
              (e) => e.toString(),
              'toString()',
              equals('Invalid argument(s): No host specified in URI '),
            )));
      });
      test("Link with none existing url", () {
        var noneExistingUri = 'http://none-existing.com';
        Link link = Link(
            parent: null, title: titleValue, uri: Uri.parse(noneExistingUri));
        expect(link.title, titleValue);
        expect(link.uri, Uri.parse(noneExistingUri));
        expect(link.toString(), '[$titleValue]($noneExistingUri)');
        expect(
            () async => await link.validateUriHttpGet(),
            throwsA(
              isA<SocketException>(),
            ));
      });
    });
  });

  group('class: CompleteLinkRule', () {
    group('field: expression', () {
      test("Correct Link", () {
        var rule = CompleteLinkRule();
        var markdown = "[$titleValue]($uri)";
        expect(rule.expression.hasMatch(markdown), true);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameTitle],
            titleValue);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameUri],
            uri);
      });
      test("Link without title", () {
        var rule = CompleteLinkRule();
        var markdown = "[]($uri)";
        expect(rule.expression.hasMatch(markdown), true);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameTitle],
            '');
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameUri],
            uri);
      });
      test("Link without url", () {
        var rule = CompleteLinkRule();
        var markdown = "[$titleValue]()";
        expect(rule.expression.hasMatch(markdown), true);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameTitle],
            titleValue);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameUri],
            '');
      });

      test("with spaces has match", () {
        var rule = CompleteLinkRule();
        var markdown = "[  $titleValue  ](    $uri )";
        expect(rule.expression.hasMatch(markdown), true);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameTitle],
            titleValue);
        expect(
            rule.expression
                .findCapturedGroups(markdown)[CompleteLinkRule.groupNameUri],
            uri);
      });

      test("with spaces between brackets and braces has no match", () {
        var rule = CompleteLinkRule();
        var markdown = "[  $titleValue  ]  (    $uri )";
        expect(rule.expression.hasMatch(markdown), false);
      });
    });
  });

  group('class: GitHubProjectLinkRule', () {
    group('field: expression', () {
      test("lowercase name has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[github $wikiSuffixAttribute $titleAttribute] "),
            true);
      });
      test("lowercase and uppercase name has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[GitHub  $wikiSuffixAttribute $titleAttribute]"),
            true);
      });
      test("with spaces has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[  GitHub  $wikiSuffixAttribute $titleAttribute    ]"),
            true);
      });
      test("[GitHubWiki] has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[GitHubWiki]"),
            true);
      });
    });
  });
  group('class: LinkParser', () {
    group('Complete Link', () {
      test('complete link', () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode("[$titleValue]($uri)"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, titleValue);
        expect((parsedNode.children.first as Link).uri, Uri.parse(uri));
      });

      test('complete link surrounded by text', () async {
        var parsedNode = await LinkParser()
            .parse(TestRootNode("Hello [$titleValue]($uri) world."));
        expect(parsedNode.children.length, 3);
        expect((parsedNode.children[0] as TextNode).text, 'Hello ');
        expect((parsedNode.children[1] as Link).title, titleValue);
        expect((parsedNode.children[1] as Link).uri, Uri.parse(uri));
        expect((parsedNode.children[2] as TextNode).text, ' world.');
      });

      test('GitHub link with uri becomes complete link', () async {
        var parsedNode =
        await LinkParser().parse(TestRootNode("[GitHub]($uri)"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, 'GitHub');
        expect((parsedNode.children.first as Link).uri, Uri.parse(uri));
      });
    });

    group('GitHub links', () {

      test('GitHub existing link', () async {
        var parsedNode = await LinkParser()
            .parse(TestRootNode("[GitHub $wikiSuffixAttribute $titleAttribute]"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, titleValue);
        expect(
            (parsedNode.children.first as Link).uri,
            Uri.parse(
                '${GitHubProject().uri}/$wikiSuffixValue'));
      });

      test('GitHub existing link surrounded by text', () async {
        var parsedNode = await LinkParser().parse(TestRootNode(
            "Hello [GitHub $wikiSuffixAttribute $titleAttribute] world."));

        expect(parsedNode.children.length, 3);
        expect((parsedNode.children[0] as TextNode).text, 'Hello ');
        expect((parsedNode.children[1] as Link).title, titleValue);
        expect(
            (parsedNode.children[1] as Link).uri,
            Uri.parse(
                '${GitHubProject().uri}/$wikiSuffixValue'));
        expect((parsedNode.children[2] as TextNode).text, ' world.');
      });

      test('GitHub none existing link', () async {
        expect(
            () async => await LinkParser().parse(TestRootNode(
                "[GitHub $invalidSuffixAttribute $titleAttribute]")),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals(
                  "Could not get uri: ${GitHubProject().uri}/$invalidSuffixValue in link: '[GitHub suffix=\"$invalidSuffixValue\"   title  : '$titleValue'  ]'."),
            )));
      });
      test("[GitHub] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHub]'));
        expect(parsedNode.toString(), '[GitHub project](${GitHubProject().uri})');
      });
      test("[GitHubWiki] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubWiki]'));
        expect(parsedNode.toString(), '[GitHub Wiki](${GitHubProject().wikiUri})');
      });
      test("[GitHubMilestones] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubMilestones]'));
        expect(parsedNode.toString(), '[GitHub milestones](${GitHubProject().milestonesUri})');
      });
      test("[GitHubReleases] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubReleases]'));
        expect(parsedNode.toString(), '[GitHub releases](${GitHubProject().releasesUri})');
      });
      test("[GitHubPullRequests] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubPullRequests]'));
        expect(parsedNode.toString(), '[GitHub pull requests](${GitHubProject().pullRequestsUri})');
      });
      test("[GitHubRaw] parsed to correctly", () async {
        String suffix='/main/README.md';
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubRaw suffix="$suffix"]'));
        expect(parsedNode.toString(), '[GitHub raw source file](${GitHubProject().rawUri}$suffix)');
      });


    });

    group('PubDevLinkRule links', () {


      test('PubDev existing link', () async {
        var parsedNode = await LinkParser()
            .parse(TestRootNode("[PubDev $exampleSuffixAttribute $titleAttribute]"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, titleValue);
        expect(
            (parsedNode.children.first as Link).uri,
            Uri.parse(
                '${PubDevProject().uri}/$exampleSuffixValue'));
      });

      test('PubDev existing link surrounded by text', () async {
        var parsedNode = await LinkParser().parse(TestRootNode(
            "Hello [PubDev $exampleSuffixAttribute $titleAttribute] world."));

        expect(parsedNode.children.length, 3);
        expect((parsedNode.children[0] as TextNode).text, 'Hello ');
        expect((parsedNode.children[1] as Link).title, titleValue);
        expect(
            (parsedNode.children[1] as Link).uri,
            Uri.parse(
                '${PubDevProject().uri}/$exampleSuffixValue'));
        expect((parsedNode.children[2] as TextNode).text, ' world.');
      });

      test('PubDev none existing link', () async {
        expect(
                () async => await LinkParser().parse(TestRootNode(
                "[PubDev $invalidSuffixAttribute $titleAttribute]")),
            throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
              'toString()',
              equals(
                  "Could not get uri: ${PubDevProject().uri}/$invalidSuffixValue in link: '[PubDev suffix=\"$invalidSuffixValue\"   title  : '$titleValue'  ]'."),
            )));
      });
      test("[PubDev] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDev]'));
        expect(parsedNode.toString(), '[PubDev package](${PubDevProject().uri})');
      });
      test("[PubDevChangeLog] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevChangeLog]'));
        expect(parsedNode.toString(), '[PubDev change log](${PubDevProject().changeLogUri})');
      });
      test("[PubDevVersions] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevVersions]'));
        expect(parsedNode.toString(), '[PubDev versions](${PubDevProject().versionsUri})');
      });
      test("[PubDevExample] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevExample]'));
        expect(parsedNode.toString(), '[PubDev example](${PubDevProject().exampleUri})');
      });
      test("[PubDevInstall] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevInstall]'));
        expect(parsedNode.toString(), '[PubDev installation](${PubDevProject().installUri})');
      });
      test("[PubDevScore] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevScore]'));
        expect(parsedNode.toString(), '[PubDev score](${PubDevProject().scoreUri})');
      });
      test("[PubDevLicense] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[PubDevLicense]'));
        expect(parsedNode.toString(), '[PubDev license](${PubDevProject().licenseUri})');
      });





    });

  });
}

class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}
