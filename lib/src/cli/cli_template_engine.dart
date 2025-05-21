import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';

class CliTemplateEngine extends TemplateEngine {
  CliTemplateEngine()
    : super(
        tagStart: '[[',
        tagEnd: ']]',
        functionGroups: createDocumentationFunctionGroups(),
      );
}
