import 'package:build/build.dart';
import 'package:documentation_builder/builders/template_builder.dart';
import 'package:documentation_builder/parser/parser.dart';

/// All information needed to generate the markdown documentation files.
class DocumentationModel extends RootNode {
  //admittedly yuki: adding the buildStep so we can assess the resolver if need to.
  BuildStep? buildStep;

  /// adds a [MarkdownTemplate] while verifying that each [MarkdownTemplate]
  /// has a unique [MarkdownTemplate.destinationFilePath] to prevent overriding generated files
  void add(MarkdownTemplate markdownPage) {
    verifyUniqueDestinationPath(markdownPage);
    children.add(markdownPage);
  }

  /// all [MarkdownTemplate]s should be stored into the [DocumentationModel.children]
  /// This accessor gets all the [MarkdownTemplate]s
  List<MarkdownTemplate> get markdownPages =>
      children.whereType<MarkdownTemplate>().toList();

  void verifyUniqueDestinationPath(MarkdownTemplate newMarkdownPage) {
    try {
      MarkdownTemplate existingMarkDownPageWithSameDestination =
          markdownPages.firstWhere((existingMarkDownPage) =>
              newMarkdownPage.destinationFilePath ==
              existingMarkDownPage.destinationFilePath);
      throw Exception(
          '${newMarkdownPage.sourceFilePath} and ${existingMarkDownPageWithSameDestination.sourceFilePath} both have the same destination path: ${newMarkdownPage.destinationFilePath}');
    } on StateError {
      // No double destination paths found. Perfect!
    }
  }
}

/// A [Resource] containing the [DocumentationModel] so that it can be shared between builders.
final resource = Resource(() => DocumentationModel());
