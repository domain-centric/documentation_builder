import 'dart:io';

import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/attribute_parser.dart';
import 'package:documentation_builder/parser/badge_parser.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_parser.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:test/test.dart';

const green='green';
const toolTip = 'tooltip';
const label = 'label';
const message = 'message';
const defaultColor='informational';
final uri = Uri.parse('https://www.google.com');

main() {
  group('class: CustomBadge', () {
    group('method: toString', () {
      test("without tooltip and color", () {
        var badge = CustomBadge(
          label: label,
          message: message,
          link: uri,
        );
        expect(badge.toString(), '[!(https://img.shields.io//badge/$label-$message-$defaultColor)]($uri)');
      });
      test("without tooltip", () {
        var badge = CustomBadge(
          label: 'label',
          message: 'message',
          color: 'green',
          link: Uri.parse('https://www.google.com'),
        );
        expect(badge.toString(), '[!(https://img.shields.io//badge/$label-$message-$green)]($uri)');
      });
      test("without color", () {
        var badge = CustomBadge(
          toolTip: toolTip,
          label: 'label',
          message: 'message',
          link: Uri.parse('https://www.google.com'),
        );
        expect(badge.toString(), '[![$toolTip](https://img.shields.io//badge/$label-$message-$defaultColor)]($uri)');
      });
    });
  });

  group('class: CustomBadgeRule', () {
    group('field: expression', () {
      test("lowercase tag name has match", () {
        var rule = CustomBadgeRule();
        expect(
            rule.expression.hasMatch("[!custombadge $label='$label' $message='$message' $uri='$uri']"),
            true);
      });
      test("lowercase and uppercase badge name has match", () {
        var rule = CustomBadgeRule();
        expect(
            rule.expression
                .hasMatch("[!CustomBadge $label='$label' $message='$message' $uri='$uri']"),
            true);
      });
      test("lowercase and uppercase badge name with spaces has match", () {
        var rule = CustomBadgeRule();
        expect(
            rule.expression
                .hasMatch("[ ! CustomBadge   $label='$label'  $message='$message'    link='$uri'    ]"),
            true);
      });
    });
    group('class: BadgeParser', () {
      test('with tooltip, label, message, color, link attributes', () async {
        var parsedNode = await BadgeParser()
            .parse(TestRootNode("[!CustomBadge $toolTip='$toolTip' $label='$label' $message='$message' color='$green' link='$uri' ]"));

        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is Badge, true);
        expect(parsedNode.children.first.toString(), '[![$toolTip](https://img.shields.io//badge/$label-$message-$green)]($uri)');
      });

      test('missing optional attribute tooltip', () async {
        var parsedNode = await BadgeParser()
            .parse(TestRootNode("[!CustomBadge $label='$label' $message='$message' color='$green' link='$uri' ]"));

        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is CustomBadge, true);
        expect(parsedNode.children.first.toString(),  '[!(https://img.shields.io//badge/$label-$message-$green)]($uri)');
      });

      test('missing required label attribute', () {
        var text="[!CustomBadge $toolTip='$toolTip' $message='$message' color='$green' link='$uri' ]";
        expect(
            () async => await BadgeParser().parse(TestRootNode(text)),
            throwsA(isA<ParserWarning>().having(
                (e) => e.toString(),
                'toString()',
                equals(
                    "Required label attribute is missing in badge: '$text'."))));
      });

      test('invalid attribute', () {
        var text="[!CustomBadge $toolTip='$toolTip' $message='$message' 123 color='$green' link='$uri' ]";
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
}


class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}
