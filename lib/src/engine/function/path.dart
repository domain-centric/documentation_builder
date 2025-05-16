import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/src/builder/documentation_builder.dart';
import 'package:documentation_builder/src/engine/function/link.dart';
import 'package:template_engine/template_engine.dart';

/// [Function]s from the [template_engine] package and this package
/// in an order that makes most sense for documentation_builder
class MergedPathFunctions extends FunctionGroup {
  static const String groupName = 'Path Functions';

  MergedPathFunctions()
      : super(groupName, [
          ...pathFunctionsFromTemplateEnginePackage(),
          InputPath(),
          OutputPath(),
          for (var link in LinkFunctions().whereType<LinkFunction>())
            UriFunction.createFromLinkFunction(link)
        ]);

  static Iterable<ExpressionFunction<Object>> pathFunctionsFrom(
          List<FunctionGroup> functionGroupsFromTemplateEnginePackage) =>
      functionGroupsFromTemplateEnginePackage
          .where((g) => g.name == groupName)
          .flattened;

  static List<ExpressionFunction> pathFunctionsFromTemplateEnginePackage() =>
      PathFunctions();
}

class UriFunction extends ExpressionFunction<Uri> {
  UriFunction(
      {required super.name,
      super.description,
      super.parameters,
      required super.function});

  factory UriFunction.createFromLinkFunction(LinkFunction link) {
    var name =
        link.name.replaceFirst(RegExp('${LinkFunction.nameSuffix}\$'), 'Uri');
    var description = link.description!.replaceFirst(
        RegExp('^${LinkFunction.descriptionPreFix}'), 'Returns a URI of ');
    var parameters = link.parameters.where((p) => p is! TextParameter).toList();
    var function = (String position, RenderContext renderContext,
            Map<String, Object> parameters) async =>
        (await link.function(position, renderContext, parameters)).uri;
    return UriFunction(
        name: name,
        description: description,
        parameters: parameters,
        function: function);
  }
}

/// TODO change the type to [File] so we can later we can use function chaining
class InputPath extends ExpressionFunction<String> {
  InputPath()
      : super(
          name: 'inputPath',
          description: "Returns the path of the template file being used.\n"
              "Prefer to use this function over the 'templateSource' because 'inputPath' always resolves to a path",
          exampleExpression: "{{inputPath()}}",
          exampleResult: "doc/example.md",
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            BuildStep? buildStep = BuildStepVariable.of(renderContext);
            return buildStep.inputId.path;
          },
        );
}

/// TODO change the type to [File] so we can later we can use function chaining
class OutputPath extends ExpressionFunction<String> {
  OutputPath()
      : super(
          name: 'outputPath',
          description:
              'Returns the path of the file being created from the template',
          exampleExpression: "{{outputPath()}}",
          exampleResult: "doc/example.md",
          function: (
            String position,
            RenderContext renderContext,
            Map<String, Object> parameters,
          ) async {
            BuildStep? buildStep = BuildStepVariable.of(renderContext);
            return buildStep.allowedOutputs.first.path;
          },
        );
}
