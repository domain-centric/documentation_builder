import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';

/// The [DocumentationBuilder] uses the [DocumentationTemplateEngine] to parse
/// the templates and later to render the parseResult.
///
/// It has some addition functionality on top of the [TemplateEngine]
class DocumentationTemplateEngine extends TemplateEngine {
  DocumentationTemplateEngine([Grammar? grammar])
    : super(grammar ?? documentationBuilderGrammar);
}

final documentationBuilderGrammar = Grammar.standard().copyWith(
  functionGroups: documentationBuilderFunctionGroups,
);

final documentationBuilderFunctionGroups = _createDocumentationFunctionGroups();

List<FunctionGroup>? _createDocumentationFunctionGroups() {
  final functionGroups = <FunctionGroup>[
    mergedImportFunctions,
    generatorFunctions,
    pathFunctions,
    linkFunctions,
    badgeFunctions,
  ];
  functionGroups.addAll(
    _missingFunctionGroupsFromTemplateEnginePackage(functionGroups),
  );
  return functionGroups;
}

Iterable<FunctionGroup> _missingFunctionGroupsFromTemplateEnginePackage(
  List<FunctionGroup> newGroups,
) {
  var newGroupNames = newGroups.map((g) => g.name);
  return standardFunctionGroups.where(
    (original) => !newGroupNames.contains(original.name),
  );
}
