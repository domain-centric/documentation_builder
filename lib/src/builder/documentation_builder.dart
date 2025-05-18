// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/build_option_parameter.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';

/// Generates documentation files from template files.
/// This can be useful when you write documentation for a
/// [Dart](https://dart.dev/) or [Flutter](https://flutter.dev/) project
/// and want to reuse/import Dart code or Dart documentation comments.
///
/// It can generate any type of text file e.g.:
/// * [README.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#readmemd)
/// * [LICENSE.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#licensemd)
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
/// * [Import Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#import-functions)
/// * [Generator Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#generator-functions)
/// * [Path Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#path-functions)
/// * [Link Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#link-functions)
/// * [Badge Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#badge-functions)
///
/// # Breaking Changes
/// [documentation_builder] 1.0.0 has had major improvements over earlier versions:
/// * It uses the [DocumentationTemplateEngine] which is an extended version of the [TemplateEngine] from the [template_engine] package
///   * Less error prone: The builder will keep running even if one of the templates fails to parse or render.
///   * Better error messages with the position within a template file.
///   * Expressions in template file tags can be nested
///   * More features: The [DocumentationTemplateEngine] can be extended with custom:
///     * dataTypes
///     * constants
///     * functionGroups
///     * operatorGroups
///   * More consistent template syntax: now all functions
/// * The [input and output file is determined by parameters in the build.yaml file](https://github.com/domain-centric/documentation_builder/wiki/02-Getting-Started#build-option-parameter-inputpath), which is:
///   * Easier to understand than the old DocumentationBuilder conventions
///   * More flexible: It can now be configured in the build.yaml file
/// * Each generated file can have an optional [header text which can be configured in the build.yaml per output file suffix](https://github.com/domain-centric/documentation_builder/wiki/02-Getting-Started#build-option-parameter-fileheaders). 
///
/// This resulted in the following breaking changes:
/// * Tags
///   | old syntax                                                                      | new syntax |
///   |---------------------------------------------------------------------------------|------------|
///   | {ImportFile file:'OtherTemplateFile.md.template' title='# Other Template File'} | # Other Template File<br>{{importTemplate('OtherTemplateFile.md.template')}} |
///   | {ImportCode file:'file_to_import.txt' title='# Code example'}                   | # Code example<br>{{importCode('file_to_import.txt')}} |
///   | {ImportDartCode file:'file_to_import.dart' title='# Dart code example'}         | # Dart code example<br>{{importDartCode('file_to_import.dart')}} |
///   | {ImportDartDoc path='lib\my_lib.dart&#124;MyClass' title='# My Class'}          | # My Class<br>{{importDartDoc('lib\my_lib.dart&#124;MyClass')}} |
///   | {TableOfContents title='# Table of contents example'}                           | # Table of contents<br>{{tableOfContents(path='doc/template/doc/wiki')}} |
///   | {MitLicense name='John Doe'}                                                    | {{license(type='MIT', name='John Doe')}} |
///   See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#import-functions) for more details on these and new functions
/// * Links
///   | old syntax               | new syntax |
///   |--------------------------|------------|
///   | &#91;GitHub]             | {{gitHubLink()}} |
///   | &#91;GitHubWiki]         | {{gitHubWikiLink()}} |
///   | &#91;GitHubStars]        | {{gitHubStarsLink()}} |
///   | &#91;GitHubIssues]       | {{gitHubIssuesLink()}} |
///   | &#91;GitHubMilestones]   | {{gitHubMilestonesLink()}} |
///   | &#91;GitHubReleases]     | {{gitHubReleasesLink()}} |
///   | &#91;GitHubPullRequests] | {{gitHubPullRequestsLink()}} |
///   | &#91;GitHubRaw]          | {{referenceLink('ref')}} or{{gitHubRawLink()}} |
///   | &#91;PubDev]             | {{pubDevLink()}} |
///   | &#91;PubDevChangeLog]    | {{pubDevChangeLogLink()}} |
///   | &#91;PubDevVersions]     | {{pubDevVersionsLink()}} |
///   | &#91;PubDevExample]      | {{pubDevExampleLink()}} |
///   | &#91;PubDevInstall]      | {{pubDevInstallLink()}} |
///   | &#91;PubDevScore]        | {{pubDevScoreLink()}} |
///   | &#91;PubDevLicense]      | {{pubDevLicenseLink()}} |
///   | PubDev package links     | {{referenceLink()}} |
///   | Dart code links          | {{referenceLink('ref')}} |
///   | Markdown file links      | &#91;title](URI) |
///   See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#link-functions) for more details on these and new functions
/// * Badges
///   | old syntax                                  | new syntax                    |
///   |---------------------------------------------|-------------------------------|
///   | &#91;CustomBadge title='title' ...]         | &#91;title]({{customBadge()}})             |
///   | &#91;PubPackageBadge title='title']         | &#91;title]({{pubPackageBadge()}})         |
///   | &#91;GitHubBadge title='title']             | &#91;title]({{gitHubBadge()}})             |
///   | &#91;GitHubWikiBadge title='title']         | &#91;title]({{gitHubWikiBadge()}})         |
///   | &#91;GitHubStarsBadge title='title']        | &#91;title]({{gitHubStarsBadge()}})        |
///   | &#91;GitHubIssuesBadge title='title']       | &#91;title]({{gitHubIssuesBadge()}})       |
///   | &#91;GitHubPullRequestsBadge title='title'] | &#91;title]({{gitHubPullRequestsBadge()}}) |
///   | &#91;GitHubLicenseBadge title='title']      | &#91;title]({{gitHubLicenseBadge()}})      |
///   See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#badge-functions) for more details on these and new functions
/// * Github-Wiki pages are now generated somewhere in the project folder (e.g. doc\wiki) and need to be copied to GitHub.
///   This could be done using GitHub actions (e.g. after each commit).
///   For more information see [Automatically Publishing Wiki pages](https://github.com/domain-centric/documentation_builder/wiki/09-Publishing#automatically-publishing-wiki-pages)

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
        inputPath: [outputPath]
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
      BuildStepFileTemplate template, BuildStep buildStep) async {
    try {
      DocumentationTemplateEngine engine = DocumentationTemplateEngine();

      var parseResult = await engine.parseTemplate(template);

      var variables = await createVariables(buildStep);
      var renderResult = await engine.render(parseResult, variables);
      if (renderResult.errorMessage.isNotEmpty) {
        log.warning('${template.source}: ${renderResult.errorMessage}');
      } else {
        /// Convention: each input will have 1 output
        var outputId = buildStep.allowedOutputs.first;
        var result = normalizeNewLines(await addOptionalHeader(
            buildStep, variables, outputId, renderResult.text));
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

  Future<String> addOptionalHeader(BuildStep buildStep, VariableMap variables,
      AssetId outputId, String text) async {
    var headerTemplate = fileHeaders.findFor(outputId);
    if (headerTemplate == null) {
      return text;
    }
    var parseResult = await engine.parseTemplate(headerTemplate);
    var renderResult = await engine.render(parseResult, variables);
    if (renderResult.errorMessage.isNotEmpty) {
      log.warning(
          'Error while processing file header: ${renderResult.errorMessage}');
      return text;
    }
    return '${renderResult.text}$newLine$text';
  }

  Future<VariableMap> createVariables(BuildStep buildStep) async => {
        BuilderVariable.id: this,
        BuildStepVariable.id: buildStep,
        LibraryCacheVariable.id:
            await buildStep.fetchResource<LibraryCache>(libraryCacheResource),
        GitHubProject.id:
            await buildStep.fetchResource<GitHubProject>(gitHubProjectResource),
        PubDevProject.id:
            await buildStep.fetchResource<PubDevProject>(pubDevProjectResource),
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
    } on FormatException  {
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

  /// gets a [Map] where key = [ProjectFilePath] and value = a [LibraryElement] from the analyzer project.
  /// We cache these because creating them (parsing) takes time.
  static LibraryCache of(RenderContext context) => context.variables[id];
}

/// gets a [Map] where key = [ProjectFilePath]
/// and value = a [LibraryElement] which is parser tree from the dart source code file.
/// We cache these because creating them (parsing) takes time.
typedef LibraryCache = Map<ProjectFilePath2, LibraryElement>;

final libraryCacheResource = Resource<LibraryCache>(() => {});
final gitHubProjectResource = Resource<GitHubProject>(
    () async => await GitHubProject.createForThisProject());
final pubDevProjectResource = Resource<PubDevProject>(
    () async => await PubDevProject.createForThisProject());
