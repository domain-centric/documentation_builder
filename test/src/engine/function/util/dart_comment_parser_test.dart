import 'package:analyzer/dart/element/element.dart';
import 'package:documentation_builder/src/engine/function/util/dart_comment_parser.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:petitparser/core.dart';
import 'package:shouldly/shouldly.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';

void main() {
  group('DartDocCommentParser', () {
    late DartDocCommentParser parser;
    late RenderContext renderContext;

    setUp(() {
      parser = DartDocCommentParser();
      renderContext = RenderContext(
        engine: DocumentationTemplateEngine(),
        parsedTemplates: [],
        templateBeingRendered: TextTemplate('dummy'),
      );
    });

    test('should parse valid links with URLs', () async {
      final input = '/// [Google](https://google.com)';
      final result = await parser.parseAndRender(
        renderContext,
        DummyElement(),
        input,
      );

      result.should.beOfType<Success<String>>();
      result.value.should.be('[Google](https://google.com)');
    });

    test('should parse links without URLs and resolve them', () async {
      final input = '/// [documentation_builder]';
      final result = await parser.parseAndRender(
        renderContext,
        DummyElement(),
        input,
      );

      result.should.beOfType<Success<String>>();
      result.value.should.be(
        '[documentation_builder](https://pub.dev/packages/documentation_builder)',
      );
    });

    test('should handle invalid links gracefully', () async {
      final input = '/// [InvalidLink](invalid_url)';
      final result = await parser.parseAndRender(
        renderContext,
        DummyElement(),
        input,
      );

      result.should.beOfType<Success<String>>();
      result.value.should.be('[InvalidLink](invalid_url)');
    });

    test('should remove comment prefixes', () async {
      final input = '/// This is a comment.';
      final result = await parser.parseAndRender(
        renderContext,
        DummyElement(),
        input,
      );

      result.should.beOfType<Success<String>>();
      result.value.should.be('This is a comment.');
    });

    test('should handle mixed content', () async {
      final input =
          'Here is some text.\n'
          '[Google](https://google.com)\n'
          '[documentation_builder]\n';
      final result = await parser.parseAndRender(
        renderContext,
        DummyElement(),
        input,
      );

      result.should.beOfType<Success<String>>();
      result.value.should.be(
        'Here is some text.\n'
        '[Google](https://google.com)\n'
        '[documentation_builder](https://pub.dev/packages/documentation_builder)\n',
      );
    });
  });

  group('LinkConverter', () {
    late RenderContext renderContext;
    setUp(() {
      renderContext = RenderContext(
        engine: DocumentationTemplateEngine(),
        parsedTemplates: [],
        templateBeingRendered: TextTemplate('dummy'),
      );
    });
    test('should resolve valid pub.dev links', () async {
      final converter = ReferenceConverter('documentation_builder');
      final result = await converter.render(renderContext, DummyElement());

      result.should.be(
        '[documentation_builder](https://pub.dev/packages/documentation_builder)',
      );
    });

    test('should return unresolved link if not found', () async {
      final converter = ReferenceConverter('unknown_package');
      final result = await converter.render(renderContext, DummyElement());

      result.should.be('[unknown_package]');
    });
  });

  group('ValidateLink', () {
    late RenderContext renderContext;
    setUp(() {
      renderContext = RenderContext(
        engine: DocumentationTemplateEngine(),
        parsedTemplates: [],
        templateBeingRendered: TextTemplate('dummy'),
      );
    });
    test('should validate and render valid links', () async {
      final validator = ValidateLink(
        linkText: 'Google',
        linkUrl: 'https://google.com',
      );
      final result = await validator.render(renderContext, DummyElement());

      result.should.be('[Google](https://google.com)');
    });

    test('should log warnings for invalid URLs', () async {
      final validator = ValidateLink(
        linkText: 'InvalidLink',
        linkUrl: 'invalid_url',
      );
      final result = await validator.render(renderContext, DummyElement());

      result.should.be('[InvalidLink](invalid_url)');
      // Note: Add assertions for log warnings if log capturing is implemented.
    });
  });
}

// ignore: deprecated_member_use
class DummyElement extends Element {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
