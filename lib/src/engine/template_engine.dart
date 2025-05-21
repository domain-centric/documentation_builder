import 'package:documentation_builder/documentation_builder.dart';
import 'package:documentation_builder/src/engine/function/badge.dart';
import 'package:documentation_builder/src/engine/function/generator.dart';
import 'package:documentation_builder/src/engine/function/import.dart';
import 'package:documentation_builder/src/engine/function/link.dart';
import 'package:documentation_builder/src/engine/function/path.dart';
import 'package:template_engine/template_engine.dart';

/// The [DocumentationBuilder] uses the [DocumentationTemplateEngine] to parse
/// the templates and later to render the parseResult.
///
/// It has some addition functionality on top of the [TemplateEngine]
class DocumentationTemplateEngine extends TemplateEngine {
  
   DocumentationTemplateEngine() :super(
      functionGroups: createDocumentationFunctionGroups()
    );

  
}

/// merges [FunctionGroup]s that come pre-packaged as part of the template_engine package
  /// with additional [FunctionGroup]s specific for documentation_builder
  /// where the most important documentation_builder [FunctionGroup]s are ordered first.
   List<FunctionGroup> createDocumentationFunctionGroups(
    
  ) {

    /// new function groups in order of importance for [DocumentationTemplateEngine]
    var newGroups = <FunctionGroup>[
      MergedImportFunctions(),
      GeneratorFunctions(),
      MergedPathFunctions(),
      LinkFunctions(),
      BadgeFunctions(),
    ];
    newGroups.addAll(_remainingGroups(newGroups));

    return newGroups;
  }

   Iterable<FunctionGroup> _remainingGroups(
    List<FunctionGroup> newGroups,
  ) {
    var newGroupNames = newGroups.map((g) => g.name);
    return DefaultFunctionGroups().where(
      (original) => !newGroupNames.contains(original.name),
    );
  }