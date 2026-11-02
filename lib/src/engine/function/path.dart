import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/documentation_builder.dart';
import 'package:documentation_builder/src/engine/function/link.dart';
import 'package:template_engine/template_engine.dart';

/// [Function]s from the [template_engine] package and this package
/// in an order that makes most sense for documentation_builder
final pathFunctions = FunctionGroup('Path Functions', [
  inputPathFunction,
  outputPathFunction,
  ...linkFunctions.whereType<LinkFunctionDefinition>().map(
    (linkFunction) => UriFunction.createFromLinkFunction(linkFunction),
  ),
]);

/// This class is used to create [FunctionDefinition]s
/// that return a [Uri] by copying [LinkFunctionDefinition]s.
class UriFunction extends FunctionDefinition<Uri> {
  UriFunction({
    required super.name,
    required super.documentation,
    super.parameters,
    required super.function,
  });

  factory UriFunction.createFromLinkFunction(LinkFunctionDefinition link) {
    var name = '${link.namePrefix}Uri';
    var description = 'Returns a URI of ${link.descriptionSuffix}';
    var parameters = link.parameters.where((p) => p is! TextParameter).toList();
    return UriFunction(
      name: name,
      documentation: FunctionDefinitionDocumentation(
        description: description,
        examples: [],
      ),
      parameters: parameters,
      function: (context) async => (await link.function(context)).uri,
    );
  }
}

/// Returns the path of the template file being used.
final inputPathFunction = FunctionDefinition<String>(
  name: 'inputPath',
  documentation: FunctionDefinitionDocumentation(
    description:
        "Returns the path of the template file being used.\n"
        "Prefer to use this function over the 'templateSource' because 'inputPath' always resolves to a path",
    examples: [
      ExpressionBlockExample(
        (delimiter) => "${delimiter.start}inputPath()${delimiter.end}",
      ),
    ],
  ),
  function: (context) async {
    BuildStep? buildStep = BuildStepVariable.of(context.renderContext);
    return buildStep.inputId.path;
  },
);

/// Returns the path of the file being created from the template.
final outputPathFunction = FunctionDefinition<String>(
  name: 'outputPath',
  documentation: FunctionDefinitionDocumentation(
    description: 'Returns the path of the file being created from the template',
    examples: [
      ExpressionBlockExample(
        ((delimiter) => "${delimiter.start}outputPath()${delimiter.end}"),
      ),
    ],
  ),
  function: (context) async {
    BuildStep? buildStep = BuildStepVariable.of(context.renderContext);
    return buildStep.allowedOutputs.first.path;
  },
);
