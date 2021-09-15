import 'package:build/build.dart';
import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';

/// All information needed to generate the markdown documentation files.
class DocumentationModel extends RootNode {
  //admittedly yuki: adding the buildStep so we can assess the resolver if need to.
  BuildStep? buildStep;

  Set<DartCodePath> dartCodePaths={};

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

  /// finds all [MarkdownTemplate]s and orders them with wiki pages first.
  List<MarkdownTemplate> findOrderedMarkdownTemplateFiles() {
    List<MarkdownTemplate> markdownTemplates= children
      .where((child) => child is MarkdownTemplate)
      .map<MarkdownTemplate>((child) => child as MarkdownTemplate)
      .toList();
    markdownTemplates.sort();
    return markdownTemplates;
  }
}

/// A [Resource] containing the [DocumentationModel] so that it can be shared between builder.
final resource = Resource(() => DocumentationModel());

/// common attribute names
class AttributeName {
  static const path='path';
  static const title='title';
}


/// common [RegExp] group names
class GroupName {
  static const name='name';
  static const title='title';
  static const value='value';
  static const path='path';
  static const uri='uri';
  static const attributes='attributes';
  static const dartFilePath = 'dartFilePath';
  static const dartMemberPath = 'dartMemberPath';
}