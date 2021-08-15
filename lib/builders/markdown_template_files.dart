import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/builders/markdown_template_builder.dart';
import 'package:documentation_builder/builders/tags.dart';
import 'package:documentation_builder/generic/markdown_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:fluent_regex/fluent_regex.dart';

import 'output_builder.dart';

/// [MarkdownTemplateFile]s are files with a .mdt extension that can contain:
/// - markdown text
/// - [Tag]s
/// - [Link]s
///
/// [MarkdownTemplateFile]s are converted to [GeneratedMarkdownFile]s
class MarkdownTemplateFile {}

/// [GeneratedMarkdownFile]s are files with a .md extension that are genereted
/// by the [DocumentationBuilder].
class GeneratedMarkdownFile {}

/// The [MarkdownTemplateBuilder] will create the [MarkdownPage] for each [MarkdownTemplateFile]
/// The [MarkdownPage] will put the contents of the [MarkdownTemplateFile] as [MarkdownText] in its [markdownNodes]
/// Other Builders will replace this [MarkdownText] into multiple [MarkDownNode] implementations if needed.
/// The [OutputBuilder] converts each [MarkdownPage] into a [GeneratedMarkdownFile]

class MarkdownPage extends MarkdownParent {
  final BuildStep buildStep;

  /// The [MarkdownTemplateFile]
  final ProjectFilePath sourcePath;

  /// The path to where the generated [MarkdownTemplateFile] needs to be stored
  final ProjectFilePath destinationPath;

  MarkdownPage({
    required this.buildStep,
    required this.destinationPath,
  }) : sourcePath = ProjectFilePath(buildStep.inputId.path) {
    markdownNodes = _createMarkdownNodes(sourcePath);
  }

  /// Creates 2 [MarkdownNode]s:
  /// - A Markdown comment text stating that the file was generated.
  /// - The contents of the source file ([MarkdownTemplateFile]) and puts all text in a [MarkdownText]
  ///
  /// This [MarkdownText] will later be:
  /// - split up in other [MarkDownText]s
  /// - [Tag] texts will be converted to [Tag] object by the [TagBuilder]
  /// - [Link] texts will be converted to [Link] objects by the [LinkBuilder]
  static List<MarkdownNode> _createMarkdownNodes(ProjectFilePath sourcePath) => [
      ThisFileWasGeneratedComment(sourcePath),
      MarkdownText(readSourceFileText(sourcePath)),
    ];

  static String readSourceFileText(ProjectFilePath sourcePath) {
    return sourcePath.toFile().readAsStringSync();
  }
}

/// Represents a Markdown comment stating that the file was generated:
/// - With what template file
/// - How (using the [DocumentationBuilder])
/// - At what date and time
class ThisFileWasGeneratedComment extends MarkdownNode {
  final ProjectFilePath sourcePath;

  ThisFileWasGeneratedComment(this.sourcePath);

  @override
  String toMarkDownText() =>
      '[//]: # (This file was generated from: ${sourcePath.toString()} using the documentation_builder package on: ${DateTime.now()}.)\n';
}

abstract class MarkdownTemplateFileFactory {
  FluentRegex get fileNameExpression;

  ProjectFilePath createDestinationPath(String sourcePath);

  bool canCreateFor(String markdownTemplatePath) {
    return fileNameExpression.hasMatch(markdownTemplatePath);
  }

  MarkdownPage createMarkdownPage(BuildStep buildStep) {
    String sourcePath = buildStep.inputId.path;
    return MarkdownPage(
      buildStep: buildStep,
      destinationPath: createDestinationPath(sourcePath),
    );
  }
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
/// A README.mdt is a [MarkdownPage] that is used by the [OutputBuilder] to create or override! the README.md file in the root of your dart project.
class ReadMeFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('readme.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('README.md');
}

/// CHANGELOG.mdt files are .....TODO explain what a CHANGELOG file is and what it should contain.
/// A CHANGELOG.mdt is a [MarkdownPage] that is used by the [OutputBuilder] to create or override! the CHANGELOG.mdt file in the root of your dart project.
/// A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG]
/// which will generate the versions assuming you are using GitHub and mark very version as a milestone
class ChangeLogFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('changelog.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('CHANGELOG.md');
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [MarkdownPage] that is used by the [OutputBuilder] to create or override! the example.md file in the example folder of your dart project.
class ExampleFactory extends MarkdownTemplateFileFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('example.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('example/example.md');
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are markdown files.
/// See [Github Wiki pages](TODO Add link) for more information.
///
///
/// Any [MarkdownPage] is considered to be a [WikiMarkdownTemplateFile] when:
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
  ProjectFilePath createDestinationPath(String sourcePath) {
    String? wikiFileName = fileNameExpression
        .findCapturedGroups(sourcePath)
        .values
        .firstWhere((v) => v != null);
    if (wikiFileName == null) {
      throw Exception('Could not find the file name of: $sourcePath');
    }
    return ProjectFilePath('doc/wiki/$wikiFileName.md');
  }
}

//TODO LicenseFactory + LicenseTags + Year tag
