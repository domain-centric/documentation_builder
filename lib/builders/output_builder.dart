library documentation_builder;

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/generic/document_model.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

class OutputBuilder extends Builder {
  final List<String> outputPaths = _createOutputPathsRelativeToLib();

  /// '$lib$' makes the build_runner run [OutputBuilder] only one time (not for each individual file)
  @override
  Map<String, List<String>> get buildExtensions => {r'$lib$': outputPaths};

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
    for (var markdownTemplateFile in model.markdownTemplateFiles) {
      try {
        AssetId assetId = createAssetId(markdownTemplateFile);
        FutureOr<String> contents = markdownTemplateFile.toMarkDownText();
        buildStep.writeAsString(assetId, contents);
        print('Wrote: ${assetId.path}');
      } on Exception catch (e) {
        print(
            'Could not write file: ${markdownTemplateFile.destinationPath}, $e');
      }
    }
  }

  AssetId createAssetId(MarkdownTemplateFile markdownTemplateFile) =>
      AssetId(LocalProject.name, markdownTemplateFile.destinationPath);

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

    var factories = MarkdownTemplateFileFactories();
    List<String> outputPathsRelativeToLib = [];
    templateFilePaths.forEach((String sourcePath) {
      try {
        var factory = factories.firstWhere((f) => f.canCreateFor(sourcePath));
        String destinationPath = factory.createDestinationPath(sourcePath);
        String outputPathRelativeToLib = '../$destinationPath';
        outputPathsRelativeToLib.add(outputPathRelativeToLib);
      } on Error {
        // Continue
      }
    });
    print(outputPathsRelativeToLib);
    return outputPathsRelativeToLib;
  }
}
