import 'builders/documentation_builder.dart';

/// Markdown template files are files with a .mdt extension that contain markdown text and [Tag]s.
///
/// The [DocumentationBuilder] will read the [MarkdownTemplateFile] and parse them into [MarkDownText] objects.
/// These can than be converted using the [toMarkDownText] method.
abstract class MarkdownTemplateFile extends MarkDownText {
  List<MarkDownText> get markDownTexts;

  String toMarkDownText() =>
      markDownTexts.map((e) => e.toMarkDownText()).join();

}



/// README.md files are .....TODO explain what a README file is and what it should contain.
/// A README.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the README.md file in the root of your dart project.
class ReadMeMarkdownTemplateFile extends MarkdownTemplateFile {
  @override
  // TODO: implement markDownText
  List<MarkDownText> get markDownTexts => throw UnimplementedError();
}

/// CHANGELOG.md files are .....TODO explain what a CHANGELOG file is and what it should contain.
/// A CHANGELOG.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the CHANGELOG.md file in the root of your dart project.
/// A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG]
/// which will generate the versions assuming you are using GitHub and mark very version as a milestone
class ChangeLogMarkdownTemplateFile extends MarkdownTemplateFile {
  @override
  // TODO: implement markDownText
  List<MarkDownText> get markDownTexts => throw UnimplementedError();
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the example.md file in the example folder of your dart project.
class ExampleMarkdownTemplateFile extends MarkdownTemplateFile {
  @override
  // TODO: implement markDownText
  List<MarkDownText> get markDownTexts => throw UnimplementedError();
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are markdown files.
/// See [Github Wiki pages](TODO Add link) for more information.
///
///
/// Any [MarkdownTemplateFile] is considered to be a [WikiMarkdownTemplateFile] when:
/// - Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
/// - Its name starts with 2 digits, and has a .mdt extension (e.g.: 07-Getting-Started.mdt)
class WikiMarkdownTemplateFile extends MarkdownTemplateFile {
  @override
  // TODO: implement markDownText
  List<MarkDownText> get markDownTexts => throw UnimplementedError();
}
