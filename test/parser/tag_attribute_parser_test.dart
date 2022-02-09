import 'package:documentation_builder/src/generic/documentation_model.dart';
import 'package:documentation_builder/src/generic/paths.dart';
import 'package:documentation_builder/src/parser/parser.dart';
import 'package:documentation_builder/src/parser/attribute_parser.dart';
import 'package:test/test.dart';

main() {
  group('class: StringAttributeRule', () {
    group('field: expression', () {
      test(" name='value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasMatch(" name='value'"), true);
      });
      test(" name  =    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasMatch("  name  =    'value'"), true);
      });
      test(' name  =    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasMatch(' name  =    "value"'), true);
      });
      test(" name  :    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasMatch("  name  :    'value'"), true);
      });
      test(' name  :    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasMatch(' name  :    "value"'), true);
      });
      test('name  :    "value" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch('name  :    "value"'), true);
      });
      test(' n!ame  :    "value" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' n!ame  :    "value"'), true);
      });
      test(' :    "value" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' :    "value"'), true);
      });
      test(' name -    "value" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' name -    "value"'), true);
      });

      test(' name"value" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' name"value"'), true);
      });
      test(' name="value\' has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' name"value\''), true);
      });
      test(' name="" has no match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.expression.hasNoMatch(' name""'), true);
      });
    });
    group('method: stringValueFor', () {
      test(" name='value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        RegExpMatch match = rule.expression.firstMatch(" name='value'")!;
        expect(rule.stringValueFor(match), 'value');
      });
      test(" name  =    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        RegExpMatch match = rule.expression.firstMatch("  name  =    'value'")!;
        expect(rule.stringValueFor(match), 'value');
      });
      test(' name  =    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        RegExpMatch match = rule.expression.firstMatch(' name  =    "value"')!;
        expect(rule.stringValueFor(match), 'value');
      });
      test(" name  :    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        RegExpMatch match = rule.expression.firstMatch("  name  :    'value'")!;
        expect(rule.stringValueFor(match), 'value');
      });
      test(' name  :    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        RegExpMatch match = rule.expression.firstMatch(' name  :    "value"')!;
        expect(rule.stringValueFor(match), 'value');
      });
    });
  });

  group('class: TagAttributeParser', () {
    group('method: parseToNameAndValues', () {
      test('2 valid attributes', () async {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/template/README.mtd';
        String title = '# Title';
        Map<String, dynamic> expectedAttributes = {
          AttributeName.path: ProjectFilePath(path),
          AttributeName.title: '# Title'
        };
        var attributes = await parser
            .parseToNameAndValues("  path = '$path'  title:'$title'");
        expect(attributes, expectedAttributes);
      });
      test('missing optional attribute', () async {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/template/README.mtd';
        Map<String, dynamic> expectedAttributes = {
          AttributeName.path: ProjectFilePath(path),
        };
        var attributes =
            await parser.parseToNameAndValues("  path = '$path'  ");
        expect(attributes, expectedAttributes);
      });

      test('missing required attribute', () {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String title = '# Title';
        expect(
            () => parser.parseToNameAndValues("  title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals("Required path attribute is missing"),
            )));
      });

      test('no attributes', () async {
        AttributeParser parser = AttributeParser([]);
        Map<String, dynamic> expectedAttributes = {};
        var attributes = await parser.parseToNameAndValues("");
        expect(attributes, expectedAttributes);
      });

      test('invalid text', () {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/template/README.mtd';
        String title = '# Title';

        expect(
            () => parser
                .parseToNameAndValues("  path = '$path' 123 title:'$title'"),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals("'123' could not be parsed to an attribute"),
            )));
      });
      test('invalid projectFilePath', () {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = '/invalid/path/starting/with/slash';
        String title = '# Title';
        expect(
            () =>
                parser.parseToNameAndValues(" path='$path' title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals(
                  "Invalid ProjectFilePath format: /invalid/path/starting/with/slash"),
            )));
      });
      test('empty title', () {
        AttributeParser parser = AttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/template/README.mtd';
        String title = '';
        expect(
            () =>
                parser.parseToNameAndValues(" path='$path' title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
              (e) => e.toString(),
              'toString()',
              equals("Title may not be empty"),
            )));
      });
    });
  });
}
