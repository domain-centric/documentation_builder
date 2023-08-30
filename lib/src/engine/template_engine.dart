import 'package:template_engine/template_engine.dart';

import 'function/license.dart';

class DocumentationTemplateEngine extends TemplateEngine {
  DocumentationTemplateEngine._() : super();

  static var documentationFunctionGroups = [LicenseGroup()];

  factory DocumentationTemplateEngine() {
    var engine = DocumentationTemplateEngine._();
    engine.functionGroups.addAll(documentationFunctionGroups);
    return engine;
  }
}
