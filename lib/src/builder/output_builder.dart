import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

import '../generic/documentation_model.dart';
import 'template_builder.dart';

///  The [OutputBuilder] converts each [Template] in the [DocumentationModel] into a [GeneratedFile]
class OutputBuilder extends Builder {
  /// '$lib$' makes the build_runner run [OutputBuilder] only one time
  /// (not for each individual file)
  static final inputFileExtension = r'$lib$';

  /// We write multiple files directly as file, which is illegal.
  /// Reason: see [writeFile].
  /// The outputFileExtensions therefore does not really matter.
  static final outputFileExtensions = ['.*'];

  @override
  Map<String, List<String>> get buildExtensions =>
      {inputFileExtension: outputFileExtensions};

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
    if (model.hasWikiPages) {
      _createOrClearWikiPageDirectory();
    }

    for (var markdownPage in model.markdownPages) {
      await writeFile(markdownPage);
    }
  }

  Future<void> writeFile(Template markdownPage) async {
    try {
      // [WikiTemplate] files are written in the parent folder.
      // Therefore not using the 2 following lines because they
      // do not allow to write outside the project:
      //   AssetId assetId = markdownPage.destinationFilePath.toAssetId();
      //   buildStep.writeAsString(assetId, contents);

      FutureOr<String> contents = markdownPage.toString();
      var filePath = markdownPage.destinationFilePath.absoluteFilePath;
      File(filePath).writeAsString(await contents);
    } on Exception catch (e, stacktrace) {
      print(
          'Could not write file: ${markdownPage.destinationFilePath}\n$e\n$stacktrace');
    }
  }

  void _createOrClearWikiPageDirectory() {
    var directory = Directory(WikiTemplate.destinationDirectoryPath);
    if (directory.existsSync()) {
      _clearWikiPageDirectory(directory);
    } else {
      directory.createSync();
    }
  }

  void _clearWikiPageDirectory(Directory directory) {
    List<FileSystemEntity> children = directory.listSync();
    for (FileSystemEntity child in children) {
      if (!_isGitFolder(child)) {
        child.delete();
      }
    }
  }

  bool _isGitFolder(FileSystemEntity child) =>
      child is Directory && child.path.endsWith('.git');
}
