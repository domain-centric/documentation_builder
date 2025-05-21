import 'package:documentation_builder/src/engine/function/generator.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('License', () {
    final engine = DocumentationTemplateEngine();

    test('should generate MIT license text', () async {
      final parseResult = await engine
          .parseText("{{ license(type='MIT', name='John Doe', year=2023)}}");
      final renderResult = await engine.render(parseResult);
      renderResult.errorMessage.should.beNullOrEmpty();
      renderResult.text.should.be(MitLicense().text(2023, 'John Doe'));
    });

    test('should generate BSD3 license text', () async {
      final parseResult = await engine
          .parseText("{{ license( name='John Doe', type='BSD3', year=2020 )}}");
      final renderResult = await engine.render(parseResult);
      renderResult.errorMessage.should.beNullOrEmpty();
      renderResult.text.should.be(Bsd3License().text(2020, 'John Doe'));
    });

    test('should use current year if year is not provided', () async {
      final parseResult =
          await engine.parseText('{{license(type= "MIT", name= "Jane Doe") }}');
      final renderResult = await engine.render(parseResult);
      renderResult.errorMessage.should.beNullOrEmpty();
      renderResult.text.should
          .be(MitLicense().text(DateTime.now().year, 'Jane Doe'));
    });

    test('should throw error for unsupported license type', () async {
      var parseResult = await engine
          .parseText('{{ license(type="INVALID", name="John Doe") }}');
      final renderResult = await engine.render(parseResult);
      renderResult.errorMessage.should.contain(
          "Render error in: '{{ license(type=\"INVALID\", name=\"John Do...':");
      renderResult.errorMessage.should.contain(
          "1:4: Invalid argument(s) (type): 'INVALID' is not on of the supported license types: MIT, BSD3.");
    });
  });
}
