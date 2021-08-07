import 'dart:async';

import 'package:build/build.dart';
import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/generic/document_model.dart';
import 'package:documentation_builder/markdown_template_files.dart';

/// Finds .mdt files, parses them into models and puts them in the DocumentationModel
class MarkdownTemplateBuilder implements Builder {

  /// '.mdt' makes the build_runner run [MarkdownTemplateBuilder] for every file with a .mdt extension
  /// This builder stores the result in the [DocumentationModel] resource  to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        '.mdt': ['dummy.dummy']
      };

  /// For each [MarkdownTemplateFile] the [MarkdownTemplateBuilder] will:
  /// - try to find a matching [MarkdownTemplateFileFactory]
  /// - create a [MarkdownTemplateFile] object that converts the text to [MarkDownText] objects.
  /// - this [MarkdownTemplateFile] object is than stored inside the [DocumentationModel] to be further processed by other Builders
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    //TODO
    // String sourceFilePath=buildStep.inputId.path;
    // var factories=MarkdownTemplateFileFactories();


    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
  }
}
