import 'dart:io';

import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/attribute_parser.dart';
import 'package:documentation_builder/parser/link_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:test/test.dart';

main() {
  String suffixName = UriSuffixAttribute().name;
  String wikiSuffixValue = 'wiki';
  String wikiSuffixAttribute = '$suffixName="$wikiSuffixValue"';
  String exampleSuffixValue = 'example';
  String exampleSuffixAttribute = '$suffixName="$exampleSuffixValue"';
  String invalidSuffixValue = 'none-existing-path-suffix';
  String invalidSuffixAttribute = '$suffixName="$invalidSuffixValue"';
  String titleName = TitleAttribute().name;
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
        var rule = CompleteLink();
        var markdown = "[$titleValue]($uri)";
        expect(rule.expression.hasMatch(markdown), true);
        expect(rule.expression.findCapturedGroups(markdown)[GroupName.title],
            titleValue);
        expect(
            rule.expression.findCapturedGroups(markdown)[GroupName.uri], uri);
      });
      test("Link without title", () {
        var rule = CompleteLink();
        var markdown = "[]($uri)";
        expect(rule.expression.hasMatch(markdown), true);
        expect(
            rule.expression.findCapturedGroups(markdown)[GroupName.title], '');
        expect(
            rule.expression.findCapturedGroups(markdown)[GroupName.uri], uri);
      });
      test("Link without url", () {
        var rule = CompleteLink();
        var markdown = "[$titleValue]()";
        expect(rule.expression.hasMatch(markdown), true);
        expect(rule.expression.findCapturedGroups(markdown)[GroupName.title],
            titleValue);
        expect(rule.expression.findCapturedGroups(markdown)[GroupName.uri], '');
      });

      test("with spaces has match", () {
        var rule = CompleteLink();
        var markdown = "[  $titleValue  ](    $uri )";
        expect(rule.expression.hasMatch(markdown), true);
        expect(rule.expression.findCapturedGroups(markdown)[GroupName.title],
            titleValue);
        expect(
            rule.expression.findCapturedGroups(markdown)[GroupName.uri], uri);
      });

      test("with spaces between brackets and braces has no match", () {
        var rule = CompleteLink();
        var markdown = "[  $titleValue  ]  (    $uri )";
        expect(rule.expression.hasMatch(markdown), false);
      });
    });
  });

  group('class: GitHubProjectLinkRule', () {
    group('field: expression', () {
      test("lowercase name has match", () {
        var rule = GitHubProjectLink();
        expect(
            rule.expression
                .hasMatch("[github $wikiSuffixAttribute $titleAttribute] "),
            true);
      });
      test("lowercase and uppercase name has match", () {
        var rule = GitHubProjectLink();
        expect(
            rule.expression
                .hasMatch("[GitHub  $wikiSuffixAttribute $titleAttribute]"),
            true);
      });
      test("with spaces has match", () {
        var rule = GitHubProjectLink();
        expect(
            rule.expression.hasMatch(
                "[  GitHub  $wikiSuffixAttribute $titleAttribute    ]"),
            true);
      });
      test("[GitHubWiki] has match", () {
        var rule = GitHubProjectLink();
        expect(rule.expression.hasMatch("[GitHubWiki]"), true);
      });
    });
  });
  group('class: MarkdownFileLinkRule', () {
    group('field:expression', () {
      test('file name only has match', () {
        var rule = MarkdownFileLink();
        expect(rule.expression.hasMatch("[README.md]"), true);
      });
      test('file and path has match', () {
        var rule = MarkdownFileLink();
        expect(rule.expression.hasMatch("[doc/template/README.mdt]"), true);
      });
      test('wiki file has match', () {
        var rule = MarkdownFileLink();
        expect(
            rule.expression.hasMatch("[01-Documentation-Builder.mdt]"), true);
      });
    });
    group('method: createDefaultTitle', () {
      test('README.md returns README', () {
        var rule = MarkdownFileLink();
        expect(rule.createDefaultTitle("README.md"), 'README');
      });
      test("'doc/template/README.mdt' returns README", () {
        var rule = MarkdownFileLink();
        expect(rule.createDefaultTitle("doc/template/README.mdt"), 'README');
      });
      test("'01-Documentation-Builder.mdt' returns 'Documentation Builder'",
          () {
        var rule = MarkdownFileLink();
        expect(rule.createDefaultTitle("01-Documentation-Builder.mdt"),
            '01 Documentation Builder');
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
        var parsedNode = await LinkParser().parse(
            TestRootNode("[GitHub $wikiSuffixAttribute $titleAttribute]"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, titleValue);
        expect((parsedNode.children.first as Link).uri,
            Uri.parse('${GitHubProject().uri}/$wikiSuffixValue'));
      });

      test('GitHub existing link surrounded by text', () async {
        var parsedNode = await LinkParser().parse(TestRootNode(
            "Hello [GitHub $wikiSuffixAttribute $titleAttribute] world."));

        expect(parsedNode.children.length, 3);
        expect((parsedNode.children[0] as TextNode).text, 'Hello ');
        expect((parsedNode.children[1] as Link).title, titleValue);
        expect((parsedNode.children[1] as Link).uri,
            Uri.parse('${GitHubProject().uri}/$wikiSuffixValue'));
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
        expect(
            parsedNode.toString(), '[GitHub project](${GitHubProject().uri})');
      });
      test("[GitHubWiki] parsed to correctly", () async {
        var parsedNode = await LinkParser().parse(TestRootNode('[GitHubWiki]'));
        expect(
            parsedNode.toString(), '[GitHub Wiki](${GitHubProject().wikiUri})');
      });
      test("[GitHubMilestones] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[GitHubMilestones]'));
        expect(parsedNode.toString(),
            '[GitHub milestones](${GitHubProject().milestonesUri})');
      });
      test("[GitHubReleases] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[GitHubReleases]'));
        expect(parsedNode.toString(),
            '[GitHub releases](${GitHubProject().releasesUri})');
      });
      test("[GitHubPullRequests] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[GitHubPullRequests]'));
        expect(parsedNode.toString(),
            '[GitHub pull requests](${GitHubProject().pullRequestsUri})');
      });
      test("[GitHubRaw] parsed to correctly", () async {
        String suffix = '/main/README.md';
        var parsedNode = await LinkParser()
            .parse(TestRootNode('[GitHubRaw suffix="$suffix"]'));
        expect(parsedNode.toString(),
            '[GitHub raw source file](${GitHubProject().rawUri}$suffix)');
      });
    });

    group('PubDevProject links', () {
      test('PubDev existing link', () async {
        var parsedNode = await LinkParser().parse(
            TestRootNode("[PubDev $exampleSuffixAttribute $titleAttribute]"));
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Link, true);
        expect((parsedNode.children.first as Link).title, titleValue);
        expect((parsedNode.children.first as Link).uri,
            Uri.parse('${PubDevProject().uri}/$exampleSuffixValue'));
      });

      test('PubDev existing link surrounded by text', () async {
        var parsedNode = await LinkParser().parse(TestRootNode(
            "Hello [PubDev $exampleSuffixAttribute $titleAttribute] world."));

        expect(parsedNode.children.length, 3);
        expect((parsedNode.children[0] as TextNode).text, 'Hello ');
        expect((parsedNode.children[1] as Link).title, titleValue);
        expect((parsedNode.children[1] as Link).uri,
            Uri.parse('${PubDevProject().uri}/$exampleSuffixValue'));
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
        expect(
            parsedNode.toString(), '[PubDev package](${PubDevProject().uri})');
      });
      test("[PubDevChangeLog] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevChangeLog]'));
        expect(parsedNode.toString(),
            '[PubDev change log](${PubDevProject().changeLogUri})');
      });
      test("[PubDevVersions] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevVersions]'));
        expect(parsedNode.toString(),
            '[PubDev versions](${PubDevProject().versionsUri})');
      });
      test("[PubDevExample] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevExample]'));
        expect(parsedNode.toString(),
            '[PubDev example](${PubDevProject().exampleUri})');
      });
      test("[PubDevInstall] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevInstall]'));
        expect(parsedNode.toString(),
            '[PubDev installation](${PubDevProject().installUri})');
      });
      test("[PubDevScore] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevScore]'));
        expect(parsedNode.toString(),
            '[PubDev score](${PubDevProject().scoreUri})');
      });
      test("[PubDevLicense] parsed to correctly", () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode('[PubDevLicense]'));
        expect(parsedNode.toString(),
            '[PubDev license](${PubDevProject().licenseUri})');
      });
    });

    group('PubPackageLinkRule links', () {
      test('not an existing pub dev package', () async {
        var noneExistingPackage = "[none_existent_package]";
        var parsedNode =
            await LinkParser().parse(TestRootNode(noneExistingPackage));
        expect(parsedNode.toString(), noneExistingPackage);
      });

      String jsonSerializableName = 'json_serializable';
      String jsonSerializableUrl = 'https://pub.dev/packages/json_serializable';

      test('existing pub dev package', () async {
        var parsedNode =
            await LinkParser().parse(TestRootNode("[$jsonSerializableName]"));
        expect(parsedNode.toString(),
            '[$jsonSerializableName]($jsonSerializableUrl)');
      });

      test('existing pub dev package with title attribute', () async {
        String title = 'Package for json conversion';
        var parsedNode = await LinkParser()
            .parse(TestRootNode("[$jsonSerializableName title='$title']"));
        expect(parsedNode.toString(), '[$title]($jsonSerializableUrl)');
      });
    });

    group('MarkdownFileLinkRule links', () {
      var expectedReadMeUri = 'https://pub.dev/packages/documentation_builder';

      test('not an none existing MarkdownFile', () async {
        var linkPath = 'NoneExisting.mdt';
        var model = TestDocumentationModel.withLink('[$linkPath]');
        await LinkParser().parse(model);
        expect(model.link is TextNode, true);
        expect(model.link is TextNode, true);
        expect(model.link.toString(), '[$linkPath]');
      });

      test('existing markdown source file', () async {
        var linkPath = 'README.mdt';
        var model = TestDocumentationModel.withLink('[$linkPath]');
        await LinkParser().parse(model);
        expect(model.link is Link, true);
        expect(model.link.toString(), '[README]($expectedReadMeUri)');
      });

      test('existing markdown destination file', () async {
        var linkPath = 'README.md';
        var model = TestDocumentationModel.withLink('[$linkPath]');
        await LinkParser().parse(model);
        expect(model.link is Link, true);
        expect(model.link.toString(), '[README]($expectedReadMeUri)');
      });

      test('existing markdown destination file case un-sensitive', () async {
        var linkPath = 'readme.md';
        var model = TestDocumentationModel.withLink('[$linkPath]');
        await LinkParser().parse(model);
        expect(model.link is Link, true);
        expect(model.link.toString(), '[readme]($expectedReadMeUri)');
      });

      test('existing markdown file with path', () async {
        var linkPath = 'doc/template/README.mdt';
        var model = TestDocumentationModel.withLink('[$linkPath]');
        await LinkParser().parse(model);
        expect(model.link is Link, true);
        expect(model.link.toString(), '[README]($expectedReadMeUri)');
      });

      test('existing markdown file with path', () async {
        String title = 'About this project';
        var model =
            TestDocumentationModel.withLink('[README.mdt title="$title"]');
        await LinkParser().parse(model);
        expect(model.link is Link, true);
        expect(model.link.toString(), '[$title]($expectedReadMeUri)');
      });
    });
  });
}

class TestDocumentationModel extends DocumentationModel {
  TestDocumentationModel.withLink(String markdownFilePath) {
    children.add(createReadMeTemplate());
    children.add(createWikiTemplate());
    children.add(createLinkTextNode(markdownFilePath));
  }

  TextNode createLinkTextNode(String markdownFilePath) =>
      TextNode(this, markdownFilePath);

  Template createReadMeTemplate() => ReadMeTemplateFactory()
      .createTemplate(this, ProjectFilePath('doc/template/README.mdt'));

  Template createWikiTemplate() => WikiTemplateFactory().createTemplate(
      this, ProjectFilePath('doc/template/01-Documentation-Builder.mdt'));

  Node get link => children[2];
}

class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}
