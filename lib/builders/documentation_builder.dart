library documentation_builder;


import 'dart:async';

import '../markdown_template_files.dart';
import 'package:build/build.dart';

/// TODO for testing only: replace with DocumentationBuilder
class DocumentationBuilderExample extends Builder {

  @override
  Map<String, List<String>> get buildExtensions => {'pubspec.yaml':['.d1'], '.dart':['.d2'], '.mdt':['.d3']};

  @override
  FutureOr<void> build(BuildStep buildStep) {
    print ('DocumentationPreBuilder.build');
  }


}

/// Generates markdown documentation files from markdown template files.
/// It is useful when you write documentation for a dart or flutter project and want to reuse/import dart code or dart documentation comments.
/// It is not intended to generate API documentation. Use [dartdoc](https://dart.dev/tools/dartdoc) instead.
///
/// It can generate the following files:
/// - README.md file
/// - CHANGELOG.md file
/// - example.md file
/// - Github Wiki pages (also markdown files)
///
/// The first line of the generated file will contain some kind of comment stating that the file was generated:
/// - How (using the [DocumentationBuilder])
/// - With what template file
/// - At what date and time
class DocumentationBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) {
    print ('>>> DocumentationBuilder.build');
  }

  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => throw UnimplementedError();
}

/// The [DocumentationBuilder] parsed the [MarkdownTemplateFile]'s text into a list of [MarkDownText] objects
/// A class that implements [MarkDownText] is something that contains documentation text.
/// Its [toMarkDownText] method returns the documentation as generated [MarkDownText]
///
/// /// For more information on markdown See https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#links
abstract class MarkDownText {
  String toMarkDownText();
}

/// The [DocumentationBuilder] parsed the [MarkdownTemplateFile]'s text into a list of objects
/// Any text in a [MarkdownTemplateFile] that is not recognized as a [Tag] or [Link] is put into a [PlainText] object
class PlainText extends MarkDownText {
  final String text;

  PlainText(this.text);

  @override
  String toMarkDownText() =>
      text;
}



