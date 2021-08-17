import 'dart:async';

import 'package:build/build.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/generic/documentation_model.dart';

/// Finds .mdt files, parses them into models and puts them in the [DocumentationModel]
class MarkdownTemplateBuilder implements Builder {
  /// '.mdt' makes the build_runner run [MarkdownTemplateBuilder] for every file with a .mdt extension
  /// This builder stores the result in the [DocumentationModel] resource  to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        '.mdt': ['dummy.dummy']
      };

  /// For each [MarkdownPage] the [MarkdownTemplateBuilder] will:
  /// - try to find a matching [MarkdownTemplateFileFactory]
  /// - create a [MarkdownPage] object that converts the text to [MarkdownText] objects.
  /// - this [MarkdownPage] object is than stored inside the [DocumentationModel] to be further processed by other Builders
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var factories = MarkdownTemplateFileFactories();
    try {
      String markdownTemplatePath = buildStep.inputId.path;
      MarkdownTemplateFileFactory factory =
          factories.firstWhere((f) => f.canCreateFor(markdownTemplatePath));
      var markdownPage = factory.createMarkdownPage(buildStep);
      DocumentationModel model =
          await buildStep.fetchResource<DocumentationModel>(resource);
      verifyUniqueDestinationPath(markdownPage, model.markdownPages);
      model.markdownPages.add(markdownPage);

    } on Error  {
      print('Unknown mark down template file: ${buildStep.inputId.path}');
    }
  }

  void verifyUniqueDestinationPath(MarkdownPage newMarkdownPage, List<MarkdownPage> markdownPages) {
     try {
       MarkdownPage existingMarkDownPageWithSameDestination=
          markdownPages.firstWhere((existingMarkDownPage) => newMarkdownPage.destinationPath==existingMarkDownPage.destinationPath);
         throw Exception ('${newMarkdownPage.sourcePath} and ${existingMarkDownPageWithSameDestination.sourcePath} both have the same destination path: ${newMarkdownPage.destinationPath}');
     } on StateError  {
       // No double destination paths found. Perfect!
     }
  }
}
