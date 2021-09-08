import 'dart:io';

import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_attribute_parser.dart';
import 'package:documentation_builder/parser/tag_parser.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('class: ImportFileTagRule', () {
    String pathName = 'path';
    String pathValue = 'doc/template/README.md';
    String invalidPathValue = 'doc\\template\\README.md';
    String pathAttribute = '$pathName="$pathValue"';
    String invalidPathAttribute = '$pathName="$invalidPathValue"';
    String titleName = 'title';
    String titleValue = '# Title';
    String invalidTitleValue = '';
    String titleAttribute = "  $titleName  : '$titleValue'  ";
    String invalidTitleAttribute = "  $titleName  : '$invalidTitleValue'  ";
    group('field: expression', () {
      test("lowercase tag name has match", () {
        var rule = ImportFileTagRule();
        expect(
            rule.expression
                .hasMatch("{importfile $pathAttribute $titleAttribute}"),
            true);
      });
      test("lowercase and uppercase tag name has match", () {
        var rule = ImportFileTagRule();
        expect(
            rule.expression
                .hasMatch("{ImportFile  $pathAttribute $titleAttribute}"),
            true);
      });
      test("lowercase and uppercase tag name has match", () {
        var rule = ImportFileTagRule();
        expect(
            rule.expression.hasMatch(
                " {  ImportFile  $pathAttribute $titleAttribute    } "),
            true);
      });
    });
    group('class: TagParser', () {
      test('2 valid attributes', () async {
        var parsedNode = await TestParser()
            .parse(TestRootNode("{  TestTag $pathAttribute $titleAttribute}"));

        Map<String, dynamic> expectedMap = {
          '$pathName': ProjectFilePath(pathValue),
          '$titleName': '$titleValue'
        };
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is TestTag, true);
        expect((parsedNode.children.first as TestTag).attributeNamesAndValues,
            expectedMap);
      });

      test('missing optional attribute', () async {
        var parsedNode = await TestParser()
            .parse(TestRootNode("{  TestTag $pathAttribute }"));
        Map<String, dynamic> expectedMap = {
          '$pathName': ProjectFilePath(pathValue),
        };
        expect(parsedNode.children.length, 1);
        expect(parsedNode.children.first is TestTag, true);
        expect((parsedNode.children.first as TestTag).attributeNamesAndValues,
            expectedMap);
      });

      test('missing required attribute', () {
        var text = "{  TestTag $titleAttribute}";
        expect(
            () => TestParser().parse(TestRootNode(text)),
            throwsA(isA<ParserWarning>().having(
                (e) => e.toString(),
                'toString()',
                equals(
                    "Required path attribute is missing in tag: '$text'."))));
      });

      test('invalid attribute text', () {
        var text = "{  TestTag $pathAttribute 123 $titleAttribute}";
        expect(
            () => TestParser().parse(TestRootNode(text)),
            throwsA(isA<ParserWarning>().having(
                (e) => e.toString(),
                'toString()',
                equals(
                    "'123' could not be parsed to an attribute in tag: '$text'."))));
      });
      test('invalid path value', () {
        var text = "{  TestTag $invalidPathAttribute $titleAttribute}";
        expect(
            () => TestParser().parse(TestRootNode(text)),
            throwsA(isA<ParserWarning>().having(
                (e) => e.toString(),
                'toString()',
                equals(
                    "Invalid ProjectFilePath format: $invalidPathValue in tag: '$text'."))));
      });
      test('invalid title value', () {
        var text = "{  TestTag $pathAttribute $invalidTitleAttribute}";
        expect(
            () => TestParser().parse(TestRootNode(text)),
            throwsA(isA<ParserWarning>().having(
                (e) => e.toString(),
                'toString()',
                equals("Title may not be empty in tag: '$text'."))));
      });
    });
  });
  group('class: Anchor', () {
    group('constructor:', () {
      test('title with special characters', () {
        var title = 'a1@#\$\\/%^&*()_z';
        var expectedName = 'a1-z';
        expect(createTestAnchor(title).name, expectedName);
        expect(createTestAnchor(title).html, "<a id='$expectedName'></a>");
        expect(
            createTestAnchor(title).uriToAnchor,
            Uri.parse('https://pub.dev/packages/documentation_builder#a1-z')
        );
      });
      test('title with hyphens', () {
        var title = 'A-sentence-with-hyphens';
        var expectedName = title.toLowerCase();
        expect(createTestAnchor(title).name, expectedName);
        expect(createTestAnchor(title).html, "<a id='$expectedName'></a>");
        expect(
            createTestAnchor(title).uriToAnchor,
            Uri.parse('https://pub.dev/packages/documentation_builder#$expectedName'));
      });
      test('title with double hyphens', () {
        var title = 'A------sentence-with--multiple---hyphens';
        var expectedName = 'a-sentence-with-multiple-hyphens';
        expect(createTestAnchor(title).name, expectedName);
        expect(createTestAnchor(title).html, "<a id='$expectedName'></a>");
        expect(
            createTestAnchor(title).uriToAnchor,
            Uri.parse('https://pub.dev/packages/documentation_builder#$expectedName'));
      });
      test('title starting with hyphen', () {
        var title = '-A sentence starting with a hyphen';
        var expectedName = 'a-sentence-starting-with-a-hyphen';
        expect(createTestAnchor(title).name, expectedName);
        expect(createTestAnchor(title).html, "<a id='$expectedName'></a>");
        expect(
            createTestAnchor(title).uriToAnchor,
            Uri.parse('https://pub.dev/packages/documentation_builder#$expectedName'));
      });
      test('title starting with hyphens', () {
        var title = '---A sentence starting with hyphens';
        var expectedName = 'a-sentence-starting-with-hyphens';
        expect(createTestAnchor(title).name, expectedName);
        expect(createTestAnchor(title).html, "<a id='$expectedName'></a>");
        expect(
            createTestAnchor(title).uriToAnchor,
            Uri.parse('https://pub.dev/packages/documentation_builder#$expectedName'));
      });
    });
  });
  group('class: Title', () {
    group('constructor:', () {
      test('Creating a Title ', () {
        var string = Title(TestRootNode(''), '## Paragraph Title').toString();
        expect(
            string,
            "<a id=\'paragraph-title\'></a>\n"
            "## Paragraph Title\n");
      });
    });
  });
  group('class: TitleAndOrAnchor', () {
    group('constructor:', () {
      test(
          'Creating a TitleAndOrAnchor object containing children with a anchor and title',
          () {
        expect(
            TitleAndOrAnchor(TestRootNode(''), '## Paragraph Title', 'test')
                .toString(),
            '<a id=\'paragraph-title\'></a>\n'
            '## Paragraph Title\n');
      });
      test(
          'Creating a TitleAndOrAnchor object containing children with a anchor',
          () {
        expect(
            TitleAndOrAnchor(TestRootNode(''), null,
                    'builder/documentation_builder|DocumentationBuilder')
                .toString(),
            "<a id='builder-documentation-builder-documentationbuilder'></a>");
      });
    });
  });

  group('class: ImportFileTag', () {
    group('constructor:', () {
      test(
          'Creating a ImportFileTag results in an object containing children with a anchor, title and markdown text',
          () async {
        ProjectFilePath filePath = ProjectFilePath('doc/template/README.mdt');
        Map<String, dynamic> attributes = {
          'path': filePath,
          'title': '## Paragraph Title'
        };
        var expectedPreFix = "<a id=\'paragraph-title\'></a>\n"
            "## Paragraph Title\n";
        var tag = ImportFileTag(TestRootNode(''), attributes);
        var newChildren = await tag.createChildren();
        tag.children.addAll(newChildren);
        var output = tag.toString();
        expect(output, startsWith(expectedPreFix));
        expect(output.length, greaterThan(expectedPreFix.length));
      });

      test(
          'Creating a ImportFileTag results in an object containing children with a anchor and markdown text',
          () async {
        ProjectFilePath filePath = ProjectFilePath('doc/template/README.mdt');
        Map<String, dynamic> attributes = {
          'path': filePath,
        };
        var expectedPreFix = "<a id=\'doc-template-readme-mdt\'></a>";
        var tag = ImportFileTag(TestRootNode(''), attributes);
        var newChildren = await tag.createChildren();
        tag.children.addAll(newChildren);
        var output = tag.toString();
        expect(output, startsWith(expectedPreFix));
        expect(output.length, greaterThan(expectedPreFix.length));
      });
    });
  });
  group('class: ImportCodeTag', () {
    group('constructor:', () {
      test(
          'Creating a ImportCodeTag results in an object containing children with a anchor, title and markdown text',
          () async {
        ProjectFilePath filePath =
            ProjectFilePath('test/parser/import_test_code_file.dart');
        Map<String, dynamic> attributes = {
          'path': filePath,
          'title': '## Paragraph Title'
        };
        var expected = '<a id=\'paragraph-title\'></a>\n'
            '## Paragraph Title\n'
            '\n'
            '```\n'
            'main() {\r\n'
            '  print(\'test\');\r\n'
            '}\n'
            '```\n';
        var tag = ImportCodeTag(TestRootNode(''), attributes);
        var newChildren = await tag.createChildren();
        tag.children.addAll(newChildren);
        var output = tag.toString();
        expect(output, expected);
      });
      test(
          'Creating a ImportCodeTag results in an object containing children with a anchor and markdown text',
          () async {
        ProjectFilePath filePath =
            ProjectFilePath('test/parser/import_test_code_file.dart');
        Map<String, dynamic> attributes = {
          'path': filePath,
        };
        var expected =
            '<a id=\'test-parser-import-test-code-file-dart\'></a>\n'
            '```\n'
            'main() {\r\n'
            '  print(\'test\');\r\n'
            '}\n'
            '```\n';
        var tag = ImportCodeTag(TestRootNode(''), attributes);
        var newChildren = await tag.createChildren();
        tag.children.addAll(newChildren);
        var output = tag.toString();
        expect(output, expected);
      });
    });
  });
  group('class: ImportDartCodeTag', () {
    group('constructor:', () {
      // TODO test using shell to get a BuildStep
      // test(
      //     'Creating a ImportDartCodeTag results in an object containing children with a anchor, title and markdown text',
      //     () {
      //   ProjectFilePath filePath =
      //       ProjectFilePath('test/parser/import_test_code_file.dart');
      //   Map<String, dynamic> attributes = {
      //     'path': filePath,
      //     'title': '## Paragraph Title'
      //   };
      //   var expected = '<a id=\'paragraph-title\'></a>\n'
      //       '## Paragraph Title\n'
      //       '\n'
      //       '```\n'
      //       'main() {\r\n'
      //       '  print(\'test\');\r\n'
      //       '}\n'
      //       '```\n';
      //   var output = ImportDartCodeTag(TestRootNode(''), attributes).toString();
      //   expect(output, expected);
      // });
    });
  });
}

Anchor createTestAnchor(String title) {
  RootNode rootNode = RootNode();
  var markdownPage =
      ReadMeFactory().createMarkdownPage(rootNode, 'doc/template/README.mdt');
  var anchor = Anchor(markdownPage, title);
  markdownPage.children.add(anchor);
  return anchor;
}

DocumentationModel createModelFromTemplateFiles() {
  DocumentationModel model = DocumentationModel();

  Directory directory = LocalProject.directory;
  var directorPattern = FluentRegex()
      .startOfLine()
      .literal(directory.path)
      .or([FluentRegex().literal('\\'), FluentRegex().literal('/')]);
  List<String> templateFilePaths = directory
      .listSync(recursive: true)
      .where((FileSystemEntity e) => e.path.toLowerCase().endsWith('.mdt'))
      .map((FileSystemEntity e) =>
          e.path.replaceAll(directorPattern, '').replaceAll('\\', '/'))
      .toList();

  if (templateFilePaths.isEmpty) throw Exception('No template files found!');

  var factories = MarkdownTemplateFactories();
  templateFilePaths.forEach((String sourcePath) {
    try {
      var factory = factories.firstWhere((f) => f.canCreateFor(sourcePath));
      var markdownPage = factory.createMarkdownPage(model, sourcePath);
      model.add(markdownPage);
    } on Error {
      // Continue
    }
  });
  if (model.children.isEmpty) throw Exception('No MarkdownPages created.');
  return model;
}

class TestParser extends Parser {
  TestParser() : super([TestTagRule()]);
}

class TestRootNode extends RootNode {
  TestRootNode(String text) {
    children.add(TextNode(this, text));
  }
}

class TestTagRule extends TagRule {
  TestTagRule()
      : super('testTag', [
          ProjectFilePathAttributeRule(),
          TitleAttributeRule(),
        ]);

  @override
  Tag createTagNode(
          ParentNode parent, Map<String, dynamic> attributeNamesAndValues) =>
      TestTag(parent, attributeNamesAndValues);
}

class TestTag extends Tag {
  final Map<String, dynamic> attributeNamesAndValues;

  TestTag(ParentNode? parent, this.attributeNamesAndValues)
      : super(parent, attributeNamesAndValues);

  @override
  Future<List<Node>> createChildren() => Future.value([]);
}
