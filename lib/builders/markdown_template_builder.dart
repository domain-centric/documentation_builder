import 'dart:async';

import 'package:build/build.dart';
import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/generic/document_model.dart';

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
  /// - create a [MarkdownTemplateFile] object that converts the text to [MarkdownText] objects.
  /// - this [MarkdownTemplateFile] object is than stored inside the [DocumentationModel] to be further processed by other Builders
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var factories = MarkdownTemplateFileFactories();
    try {
      MarkdownTemplateFileFactory factory =
          factories.firstWhere((f) => f.canCreateFor(buildStep));
      var markdownTemplateFile = factory.create(buildStep);
      DocumentationModel model =
          await buildStep.fetchResource<DocumentationModel>(resource);
      print('>>>YES');
      model.markdownTemplateFiles.add(markdownTemplateFile);
    } on Error  {
      print('Unknown mark down template file: ${buildStep.inputId.path}');
    }
  }
}
