import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'template_builder.dart';

///  The [OutputBuilder] converts each [Template] in the [DocumentationModel] into a [GeneratedFile]
class OutputBuilder extends Builder {
  final List<String> outputPaths = _createOutputPathsRelativeToLib();

  /// '$lib$' makes the build_runner run [OutputBuilder] only one time (not for each individual file)
  @override
  Map<String, List<String>> get buildExtensions => {r'$lib$': outputPaths};

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
    for (var markdownPage in model.markdownPages) {
      try {
        AssetId assetId = markdownPage.destinationFilePath.toAssetId();
        FutureOr<String> contents = markdownPage.toString();
        buildStep.writeAsString(assetId, contents);
      } on Exception catch (e) {
        print('Could not write file: ${markdownPage.destinationFilePath}, $e');
      }
    }
  }

  static List<String> _createOutputPathsRelativeToLib() {
    Directory directory = LocalProject.directory;
    var directorPattern = FluentRegex()
        .startOfLine()
        .literal(directory.path)
        .or([FluentRegex().literal('\\'), FluentRegex().literal('/')]);
    List<String> templateFilePaths = directory
        .listSync(recursive: true)
        .where((FileSystemEntity e) => e.path.toLowerCase().endsWith('.mdt'))
        .map((FileSystemEntity e) =>
            e.path.replaceAll(directorPattern, '').replaceAll('\\', '/'))
        .toList();

    var dummy = DocumentationModel();
    var factories = TemplateFactories();
    List<String> outputPathsRelativeToLib = [];
    templateFilePaths.forEach((String sourcePath) {
      try {
        var factory = factories.firstWhere((f) => f.canCreateFor(sourcePath));
        String outputPathRelativeToLib = factory
            .createTemplate(dummy, ProjectFilePath(sourcePath))
            .destinationFilePath
            .relativeToLibDirectory;
        outputPathsRelativeToLib.add(outputPathRelativeToLib);
      } on Error {
        // Continue
      }
    });
    return outputPathsRelativeToLib;
  }
}
