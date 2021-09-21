import 'package:build/build.dart';
import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';

/// All information needed to generate the markdown documentation files.
class DocumentationModel extends RootNode {
  //admittedly yuki: adding the buildStep so we can assess the resolver if need to.
  BuildStep? buildStep;

  Set<DartCodePath> dartCodePaths={};

  /// adds a [Template] while verifying that each [Template]
  /// has a unique [Template.destinationFilePath] to prevent overriding generated files
  void add(Template markdownPage) {
    verifyUniqueDestinationPath(markdownPage);
    children.add(markdownPage);
  }

  /// all [Template]s should be stored into the [DocumentationModel.children]
  /// This accessor gets all the [Template]s
  List<Template> get markdownPages =>
      children.whereType<Template>().toList();

  void verifyUniqueDestinationPath(Template newMarkdownPage) {
    try {
      Template existingMarkDownPageWithSameDestination =
          markdownPages.firstWhere((existingMarkDownPage) =>
              newMarkdownPage.destinationFilePath ==
              existingMarkDownPage.destinationFilePath);
      throw Exception(
          '${newMarkdownPage.sourceFilePath} and ${existingMarkDownPageWithSameDestination.sourceFilePath} both have the same destination path: ${newMarkdownPage.destinationFilePath}');
    } on StateError {
      // No double destination paths found. Perfect!
    }
  }

  /// finds all [Template]s and orders them with wiki pages first.
  List<Template> findOrderedMarkdownTemplates() {
    List<Template> markdownTemplates= children
      .where((child) => child is Template)
      .map<Template>((child) => child as Template)
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