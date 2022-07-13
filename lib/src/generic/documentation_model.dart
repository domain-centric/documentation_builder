import 'package:build/build.dart';

import '../builder/documentation_model_builder.dart';
import '../parser/parser.dart';
import 'paths.dart';

/// All information needed to generate the markdown documentation files.
class DocumentationModel extends RootNode {
  //admittedly yuki: adding the buildStep so we can assess the resolver if need to.
  BuildStep? buildStep;

  Set<DartCodePath> dartCodePaths = {};

  bool get hasWikiPages => children.whereType<WikiTemplate>().isNotEmpty;

  /// adds a [Template] while verifying that each [Template]
  /// has a unique [Template.destinationFilePath] to prevent overriding generated files
  void add(DocumentationFile documentationFile) {
    verifyUniqueDestinationPath(documentationFile);
    children.add(documentationFile);
  }

  /// all [Template]s should be stored into the [DocumentationModel.children]
  /// This accessor gets all the [Template]s
  List<Template> get markdownPages => children.whereType<Template>().toList();

  List<DocumentationFile> get otharThanTempateFiles => children
      .where((child) => child is! Template)
      .cast<DocumentationFile>()
      .toList();

  void verifyUniqueDestinationPath(DocumentationFile documentationFile) {
    try {
      Template existingMarkDownPageWithSameDestination =
          markdownPages.firstWhere((existingMarkDownPage) =>
              documentationFile.destinationFilePath ==
              existingMarkDownPage.destinationFilePath);
      throw Exception(
          '${documentationFile.sourceFilePath} and ${existingMarkDownPageWithSameDestination.sourceFilePath} both have the same destination path: ${documentationFile.destinationFilePath}');
    } on StateError {
      // No double destination paths found. Perfect!
    }
  }

  /// finds all [Template]s and orders them with wiki pages first.
  List<Template> findOrderedMarkdownTemplates() {
    List<Template> markdownTemplates = children.whereType<Template>().toList();
    markdownTemplates.sort();
    return markdownTemplates;
  }
}

/// A [Resource] containing the [DocumentationModel] so that it can be shared between builder.
final resource = Resource(() => DocumentationModel());

/// common attribute names
class AttributeName {
  static const path = 'path';
  static const title = 'title';
  static const suffix = 'suffix';
  static const toolTip = 'tooltip';
  static const label = 'label';
  static const message = 'message';
  static const color = 'color';
  static const link = 'link';
  static const name = 'name';
}

/// common [RegExp] group names
class GroupName {
  static const name = 'name';
  static const title = 'title';
  static const value = 'value';
  static const path = 'path';
  static const uri = 'uri';
  static const attributes = 'attributes';
  static const dartFilePath = 'dartFilePath';
  static const dartMemberPath = 'dartMemberPath';
}
