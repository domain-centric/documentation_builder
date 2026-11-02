// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/build_config.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';

/// Generates documentation files from template files.
/// This can be useful when you write documentation for a
/// [Dart](https://dart.dev/) or [Flutter](https://flutter.dev/) project
/// and want to reuse/import files or Dart documentation comments.
///
/// It can generate any type of text file e.g.:
/// * [README.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#readmemd)
/// * [LICENSE](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#license)
/// * [CHANGELOG.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#changelogmd)
/// * [Example files](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#examplemd)
/// * [GitHub wiki files](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#pages)
/// * or any other text file
///
/// [documentation_builder] is not intended to generate API documentation.
/// Use [dartdoc](https://dart.dev/tools/dartdoc) instead.
///
/// # Features
/// [documentation_builder] uses the [template_engine] package with additional functions for documentation.
/// The most commonly used functions for documentation are:
/// * [Import Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#import-functions)
/// * [Generator Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#generator-functions)
/// * [Path Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#path-functions)
/// * [Link Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#link-functions)
/// * [Badge Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#badge-functions)
///

class DocumentationBuilder implements Builder {
  final BuilderOptions options;
  final engine = DocumentationTemplateEngine();
  VariableMap? _cachedVariables;

  late String inputPath = InputPath().getValue(options);
  late String outputPath = OutputPath().getValue(options);
  late FileHeaderMap fileHeaders = FileHeaders().getValue(options);

  DocumentationBuilder(this.options);

  /// Every template file that matches the [inputPath] expression
  /// will be read, parsed, rendered and the results will be
  /// stored according to the [outputPath] expression.
  @override
  Map<String, List<String>> get buildExtensions => {
    inputPath: [outputPath],
  };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var template = BuildStepFileTemplate(buildStep);
    if (await template.isTextFile) {
      await parseAndRenderTextTemplate(template, buildStep);
    } else {
      await copyFile(buildStep);
    }
  }

  Future<void> parseAndRenderTextTemplate(
    BuildStepFileTemplate template,
    BuildStep buildStep,
  ) async {
    try {
      DocumentationTemplateEngine engine = DocumentationTemplateEngine();

      var parseResult = await engine.parseTemplate(template);
      if (parseResult.aggregatedErrorMessage.isNotEmpty) {
        log.warning(
          '${template.source}: ${parseResult.aggregatedErrorMessage}',
        );
      }
      var variables = await createVariables(buildStep);
      var renderResult = await engine.render(parseResult, variables: variables);
      if (renderResult.aggregatedErrorMessage.isNotEmpty) {
        log.warning(
          '${template.source}: ${renderResult.aggregatedErrorMessage}',
        );
      } else {
        /// Convention: each input will have 1 output
        var outputId = buildStep.allowedOutputs.first;
        var result = normalizeNewLines(
          await addOptionalHeader(
            buildStep,
            variables,
            outputId,
            renderResult.text,
          ),
        );
        buildStep.writeAsString(outputId, result);
      }
    } catch (e, stackTrace) {
      log.severe(e, stackTrace);
    }
  }

  Future<void> copyFile(BuildStep buildStep) async {
    // Read the binary content of the image
    final bytes = await buildStep.readAsBytes(buildStep.inputId);

    for (var outputId in buildStep.allowedOutputs) {
      // Write the binary content to the new location
      await buildStep.writeAsBytes(outputId, bytes);
    }
  }

  Future<Map<String, dynamic>> getVariables(BuildStep buildStep) async {
    if (_cachedVariables == null) {}
    return _cachedVariables!;
  }

  Future<String> addOptionalHeader(
    BuildStep buildStep,
    VariableMap variables,
    AssetId outputId,
    String text,
  ) async {
    var headerTemplate = fileHeaders.findFor(outputId);
    if (headerTemplate == null) {
      return text;
    }
    var parseResult = await engine.parseTemplate(headerTemplate);
    var renderResult = await engine.render(parseResult, variables: variables);
    if (renderResult.aggregatedErrorMessage.isNotEmpty) {
      log.warning(
        'Error while processing file header: ${renderResult.aggregatedErrorMessage}',
      );
      return text;
    }
    return '${renderResult.text}$newLine$text';
  }

  Future<VariableMap> createVariables(BuildStep buildStep) async => {
    BuilderVariable.id: this,
    BuildStepVariable.id: buildStep,
    LibraryCacheVariable.id: await buildStep.fetchResource<LibraryCache>(
      libraryCacheResource,
    ),
    GitHubProject.id: await buildStep.fetchResource<GitHubProject>(
      gitHubProjectResource,
    ),
    PubDevProject.id: await buildStep.fetchResource<PubDevProject>(
      pubDevProjectResource,
    ),
  };
}

class BuildStepFileTemplate extends Template {
  final BuildStep buildStep;

  BuildStepFileTemplate(this.buildStep) {
    source = buildStep.inputId.path;
    sourceTitle = buildStep.inputId.path;
    text = buildStep.readAsString(buildStep.inputId);
  }

  Future<bool> get isTextFile async {
    try {
      await text;
      return true;
    } on FormatException {
      return false;
    }
  }
}

/// Helper class
class BuildStepVariable {
  static const String id = 'buildStep';

  /// gets the [BuildStep] from [RenderContext.variables] assuming it was put there first
  static BuildStep of(RenderContext context) => context.variables[id];
}

class BuilderVariable {
  static const String id = 'builder';

  /// gets the [Builder] from [RenderContext.variables] assuming it was put there first
  static Builder of(RenderContext context) => context.variables[id];
}

class LibraryCacheVariable {
  static const String id = 'libraryCache';

  /// gets a [Map] where key = [ProjectFilePath2]
  /// and value = a [LibraryElement] from the analyzer project.
  /// We cache these because creating them (parsing) takes time.
  static LibraryCache of(RenderContext context) => context.variables[id];
}

/// gets a [Map] where key = [ProjectFilePath2]
/// and value = a [LibraryElement] which is parser tree from the dart source code file.
/// We cache these because creating them (parsing) takes time.
typedef LibraryCache = Map<ProjectFilePath2, LibraryElement>;

final libraryCacheResource = Resource<LibraryCache>(() => {});
final gitHubProjectResource = Resource<GitHubProject>(
  () async => await GitHubProject.createForThisProject(),
);
final pubDevProjectResource = Resource<PubDevProject>(
  () async => await PubDevProject.createForThisProject(),
);
