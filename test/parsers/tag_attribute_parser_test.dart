import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
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
        expect(rule.stringValueFor(" name='value'"), 'value');
      });
      test(" name  =    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.stringValueFor("  name  =    'value'"), 'value');
      });
      test(' name  =    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.stringValueFor(' name  =    "value"'), 'value');
      });
      test(" name  :    'value' has match", () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.stringValueFor("  name  :    'value'"), 'value');
      });
      test(' name  :    "value" has match', () {
        var rule = StringAttributeRule('name', required: true);
        expect(rule.stringValueFor(' name  :    "value"'), 'value');
      });
    });
  });

  group('class: TagAttributeParser', () {
    group('method: parseToNameAndValues', () {
      test('2 valid attributes', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/templates/README.mtd';
        String title = '# Title';
        Map<String, dynamic> expectedMap = {
          'path': ProjectFilePath(path),
          'title': '# Title'
        };
        expect(parser.parseToNameAndValues("  path = '$path'  title:'$title'"),
            expectedMap);
      });
      test('missing optional attribute', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/templates/README.mtd';
        Map<String, dynamic> expectedMap = {
          'path': ProjectFilePath(path),
        };
        expect(parser.parseToNameAndValues("  path = '$path'  "),
            expectedMap);
      });

      test('missing required attribute', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String title = '# Title';
        expect(() => parser.parseToNameAndValues("  title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
              'toString()',
              equals("Required path attribute is missing"
              ),
            )));
      });

      test('no attributes', () {
        TagAttributeParser parser = TagAttributeParser([
        ]);
        Map<String, dynamic> expectedMap = {
        };
        expect(parser.parseToNameAndValues(""),
            expectedMap);
      });


      test('invalid text', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/templates/README.mtd';
        String title = '# Title';

        expect(() => parser.parseToNameAndValues("  path = '$path' 123 title:'$title'"),
            throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
              'toString()',
              equals("'123' could not be parsed to an attribute"
              ),
            )));

      });
      test('invalid projectFilePath', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = '/invalid/path/starting/with/slash';
        String title = '# Title';
        expect(() => parser.parseToNameAndValues(" path='$path' title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
              'toString()',
              equals("Invalid ProjectFilePath format: /invalid/path/starting/with/slash"
              ),
            )));
      });
      test('empty title', () {
        TagAttributeParser parser = TagAttributeParser([
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);
        String path = 'doc/templates/README.mtd';
        String title = '';
        expect(() => parser.parseToNameAndValues(" path='$path' title = '$title'  "),
            throwsA(isA<ParserWarning>().having(
                  (e) => e.toString(),
              'toString()',
              equals("Title may not be empty"
              ),
            )));

      });
    });
  });
}
