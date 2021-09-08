import 'dart:io';

import 'package:documentation_builder/parser/link_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  String suffixName = UriSuffixAttributeRule().name;
  String suffixValue = 'wiki';
  String invalidSuffixValue = 'none-existing-path-suffix';
  String suffixAttribute = '$suffixName="$suffixValue"';
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
                .hasMatch("[github $suffixAttribute $titleAttribute] "),
            true);
      });
      test("lowercase and uppercase name has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[GitHub  $suffixAttribute $titleAttribute]"),
            true);
      });
      test("with spaces has match", () {
        var rule = GitHubProjectLinkRule();
        expect(
            rule.expression
                .hasMatch("[  GitHub  $suffixAttribute $titleAttribute    ]"),
            true);
      });
    });
  });
  group('class: LinkParser', () {
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
      var parsedNode = await LinkParser().parse(TestRootNode("[GitHub]($uri)"));
      expect(parsedNode.children.length, 1);
      expect(parsedNode.children.first is Link, true);
      expect((parsedNode.children.first as Link).title, 'GitHub');
      expect((parsedNode.children.first as Link).uri, Uri.parse(uri));
    });

    test('GitHub existing link', () async {
      var parsedNode = await LinkParser()
          .parse(TestRootNode("[GitHub $suffixAttribute $titleAttribute]"));
      expect(parsedNode.children.length, 1);
      expect(parsedNode.children.first is Link, true);
      expect((parsedNode.children.first as Link).title, titleValue);
      expect(
          (parsedNode.children.first as Link).uri,
          Uri.parse(
              'https://github.com/efficientyboosters/documentation_builder/wiki'));
    });

    test('GitHub existing link surrounded by text', () async {
      var parsedNode = await LinkParser().parse(TestRootNode(
          "Hello [GitHub $suffixAttribute $titleAttribute] world."));

      expect(parsedNode.children.length, 3);
      expect((parsedNode.children[0] as TextNode).text, 'Hello ');
      expect((parsedNode.children[1] as Link).title, titleValue);
      expect(
          (parsedNode.children[1] as Link).uri,
          Uri.parse(
              'https://github.com/efficientyboosters/documentation_builder/wiki'));
      expect((parsedNode.children[2] as TextNode).text, ' world.');
    });

    test('GitHub existing link', () async {
      expect(
          () async => await LinkParser().parse(
              TestRootNode("[GitHub $invalidSuffixAttribute $titleAttribute]")),
          throwsA(isA<ParserWarning>().having(
            (e) => e.toString(),
            'toString()',
            equals(
                "Could not get uri: https://github.com/efficientyboosters/documentation_builder/none-existing-path-suffix in link: '[GitHub suffix=\"none-existing-path-suffix\"   title  : '# Title'  ]'."),
          )));
    });

  });
}

class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}
