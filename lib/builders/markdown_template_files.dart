import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'documentation_builder.dart';

/// The [DocumentationBuilder] parsed the [MarkdownTemplateFile]'s text into a list of [MarkdownText] objects
/// A class that implements [MarkdownText] is something that contains documentation text.
/// Its [toMarkDownText] method returns the documentation as generated [MarkdownText]
///
/// /// For more information on markdown See https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#links
abstract class MarkdownText {
  String toMarkDownText();
}

/// The [DocumentationBuilder] parsed the [MarkdownTemplateFile]'s text into a list of objects
/// Any text in a [MarkdownTemplateFile] that is not recognized as a [Tag] or [Link] is put into a [PlainText] object
class PlainText extends MarkdownText {
  final String text;

  PlainText(this.text);

  @override
  String toMarkDownText() => text;
}

/// Markdown template files are files with a .mdt extension that contain markdown text and [Tag]s.
///
/// The [DocumentationBuilder] will read the [MarkdownTemplateFile] and parse them into [MarkdownText] objects.
/// These can than be converted using the [toMarkDownText] method.
class MarkdownTemplateFile extends MarkdownText {
  final BuildStep buildStep;

  /// [MarkdownTemplateFile] destination path:
  /// - The path to the asset relative to the root directory of the [package] (=project directory).
  /// - Asset paths always use forward slashes as path separators, regardless of the host platform.
  /// - The path will always be within their package, that is they will never contain "../".
  /// e.g. /doc/wiki/Home.md
  final String destinationPath;
  late List<MarkdownText> markDownTexts;

  MarkdownTemplateFile({
    required this.buildStep,
    required this.destinationPath,
  }) {
    _parse(buildStep);
  }

  String toMarkDownText() =>
      markDownTexts.map((e) => e.toMarkDownText()).join();

  _parse(BuildStep buildStep) async {
    await buildStep.readAsString(buildStep.inputId).then((text) {
      //TODO find all tags and make [markDownTexts]
      markDownTexts = [PlainText(text)];
    });
  }
}

abstract class MarkdownTemplateFileFactory {
  FluentRegex get fileNameExpression;

  bool canCreateFor(BuildStep buildStep) {
    String markdownTemplatePath = buildStep.inputId.path;
    return fileNameExpression.hasMatch(markdownTemplatePath);
  }

  MarkdownTemplateFile create(BuildStep buildStep);
}

class MarkdownTemplateFileFactories
    extends DelegatingList<MarkdownTemplateFileFactory> {
  MarkdownTemplateFileFactories()
      : super([
          ReadMeFactory(),
          ChangeLogFactory(),
          ExampleFactory(),
          WikiFactory(),
        ]);
}

/// README.md files are .....TODO explain what a README file is and what it should contain.
/// A README.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the README.md file in the root of your dart project.
class ReadMeFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('readme.mdt').endOfLine().ignoreCase();

  @override
  MarkdownTemplateFile create(BuildStep buildStep) {
    return MarkdownTemplateFile(
      buildStep: buildStep,
      destinationPath: 'README.md',
    );
  }
}

/// CHANGELOG.md files are .....TODO explain what a CHANGELOG file is and what it should contain.
/// A CHANGELOG.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the CHANGELOG.md file in the root of your dart project.
/// A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG]
/// which will generate the versions assuming you are using GitHub and mark very version as a milestone
class ChangeLogFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('changelog.mdt').endOfLine().ignoreCase();

  @override
  MarkdownTemplateFile create(BuildStep buildStep) {
    return MarkdownTemplateFile(
      buildStep: buildStep,
      destinationPath: 'CHANGELOG.md',
    );
  }
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder] to create or override! the example.md file in the example folder of your dart project.
class ExampleFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('example.mdt').endOfLine().ignoreCase();

  @override
  MarkdownTemplateFile create(BuildStep buildStep) {
    return MarkdownTemplateFile(
      buildStep: buildStep,
      destinationPath: 'example/example.md',
    );
  }
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are markdown files.
/// See [Github Wiki pages](TODO Add link) for more information.
///
///
/// Any [MarkdownTemplateFile] is considered to be a [WikiMarkdownTemplateFile] when:
/// - Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
/// - Its name starts with 2 digits, and has a .mdt extension (e.g.: 07-Getting-Started.mdt)
class WikiFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression => FluentRegex()
      .or([
        FluentRegex().group(FluentRegex().literal('home'),
            type: GroupType.captureUnNamed()),
        FluentRegex().group(
            FluentRegex()
                .characterSet(CharacterSet().addDigits(), Quantity.exactly(2))
                .characterSet(
                  CharacterSet().addLetters().addDigits().addLiterals('-_'),
                  Quantity.oneOrMoreTimes(),
                ),
            type: GroupType.captureUnNamed())
      ])
      .literal('.mdt')
      .endOfLine()
      .ignoreCase();

  @override
  MarkdownTemplateFile create(BuildStep buildStep) {
    var sourcePath = buildStep.inputId.path;
    String? wikiFileName = fileNameExpression
        .findCapturedGroups(sourcePath)
        .values
        .firstWhere((v) => v != null);
    if (wikiFileName == null) {
      print('Could not find the file name of: $sourcePath');
    }
    return MarkdownTemplateFile(
      buildStep: buildStep,
      destinationPath: 'doc/wiki/$wikiFileName.md',
    );
  }
}

//TODO LicenseFactory + LicenseTags + Year tag
