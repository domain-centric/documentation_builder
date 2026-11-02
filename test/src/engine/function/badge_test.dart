import 'package:shouldly/shouldly.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/badge.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Badge function examples', () {
    late DocumentationTemplateEngine engine;
    late VariableMap variables;

    setUpAll(() async {
      engine = DocumentationTemplateEngine();
      variables = {
        GitHubProject.id: await GitHubProject.createForThisProject(),
        PubDevProject.id: await PubDevProject.createForThisProject(),
      };
    });

    for (final function in badgeFunctions) {
      for (final example
          in function.documentation.examples
              .whereType<ExpressionBlockExample>()) {
        if (example.shouldRender == null) {
          continue;
        }

        test('${function.name} example renders as documented', () async {
          final delimiter = engine.grammar.codeBlockDelimiter;
          final expression = example.expressionBlockFunction(delimiter);
          final parseResult = await engine.parseText(expression);
          final renderResult = await engine.render(
            parseResult,
            variables: {...variables, ...example.variables},
          );
          Should.satisfyAllConditions([
            () => renderResult.errors.should.beEmpty(),
            () => renderResult.text.should.be(
              normalizeNewLines(example.shouldRender!),
            ),
          ]);
        });
      }
    }
  });

  group('Badge', () {
    test('custom badge creates correct markdown', () {
      final badge = Badge.custom(
        toolTip: 'License',
        label: 'license',
        message: 'MIT',
        color: 'blue',
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[![License](https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });

    test('badge without tooltip omits tooltip in markdown', () {
      final badge = Badge(
        toolTip: null,
        image: Uri.parse('https://img.shields.io/badge/license-MIT-blue'),
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[!(https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });

    test('badge with tooltip includes tooltip in markdown', () {
      final badge = Badge(
        toolTip: 'MIT License',
        image: Uri.parse('https://img.shields.io/badge/license-MIT-blue'),
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });
  });

  group('Parameters', () {
    test('ToolTipParameter has correct name and description', () {
      final param = ToolTipParameter(PresenceOptional());
      param.name.should.be('toolTip');
      param.description.should.contain('hoovering over a badge');
    });

    test('LabelParameter has correct name and description', () {
      final param = LabelParameter(PresenceMandatory());
      param.name.should.be('label');
      param.description.should.contain('left text of the badge');
    });

    test('MessageParameter has correct name and description', () {
      final param = MessageParameter(PresenceMandatory());
      param.name.should.be('message');
      param.description.should.contain('right text of the badge');
    });

    test('ColorParameter has correct name and description', () {
      final param = ColorParameter(PresenceOptional());
      param.name.should.be('color');
      param.description.should.contain('fill color');
    });

    test('LinkParameter has correct name and description', () {
      final param = LinkParameter(PresenceMandatory());
      param.name.should.be('link');
      param.description.should.contain('Uri that points to a web site page');
    });

    test('LicenseTypeParameter has correct name and description', () {
      final param = LicenseTypeParameter(PresenceOptional());
      param.name.should.be('licenseType');
      param.description.should.contain('license type to display');
    });
  });
}
