import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';

/// A template engine for the CLI that uses the `documentation_builder` functions.
/// It uses the `[[` and `]]` tags to delimit template expressions to
/// differentiate from the {{ and }} tags is used in  [DocumentationTemplateEngine].
class CliTemplateEngine extends TemplateEngine {
  CliTemplateEngine()
    : super(
        tagStart: '[[',
        tagEnd: ']]',
        functionGroups: createDocumentationFunctionGroups(),
      );
}
