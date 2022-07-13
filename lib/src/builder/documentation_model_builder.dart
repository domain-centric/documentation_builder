import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/src/parser/tag_parser.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:logging/logging.dart';

import '../generic/documentation_model.dart';
import '../generic/paths.dart';
import '../parser/parser.dart';
import '../project/github_project.dart';
import '../project/local_project.dart';
import '../project/pub_dev_project.dart';
import 'documentation_builder.dart';

/// Finds documentation files in the project's doc folder,
/// and puts them in the [DocumentationModel]
class DocumentationModelBuilder implements Builder {
  /// Makes the build_runner run [DocumentationModelBuilder]
  /// for every file with in the projects doc/template folder
  /// This builder stores the result in the [DocumentationModel] resource
  /// to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        'doc/template/{{0}}.{{1}}': ['{{0}}.{{1}}']
      };

  /// For each [Template] the [DocumentationModelBuilder] will:
  /// - try to find a matching [DocumentationFactory]
  /// - create a [Template] object that converts the text to [MarkdownText] objects.
  /// - this [Template] object is than stored inside the [DocumentationModel] to be further processed by other Builders
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var factories = DocumentationFileFactories();
    try {
      String documentationFile = buildStep.inputId.path;
      DocumentationFactory? factory =
          factories.firstWhereOrNull((f) => f.canCreateFor(documentationFile));
      if (factory == null) {
        log.log(Level.INFO,
            'Do not know what to do with file: ${buildStep.inputId.path}.');
      } else {
        DocumentationModel model =
            await buildStep.fetchResource<DocumentationModel>(resource);
        var sourceFilePath = ProjectFilePath(buildStep.inputId.path);
        var documentation = factory.createDocument(model, sourceFilePath);

        model.add(documentation);
      }
    } catch (e, stackTrace) {
      log.log(
          Level.SEVERE,
          'Could not create mark down template file from : ${buildStep.inputId.path}. Error: \n$e',
          stackTrace);
    }
  }
}

/// [TemplateFile]s are text files with that can contain:
/// - [Markdown](https://www.markdownguide.org/cheat-sheet/) text
/// - [Tag]s
/// - [Link]s
/// - [Badge]s
///
/// [TemplateFile]s are converted to [GeneratedFile]s.
/// [TemplateFile]s are stored stored in the doc/template folders in the
/// root of the project.
class TemplateFile {}

/// [MarkdownTemplateFile]s are [TemplateFile]s that have a MarkDownTemplate (.mdt) extension.
class MarkdownTemplateFile extends TemplateFile {}

/// The [DocumentationBuilder] converts [TemplateFile]s to [GeneratedFile]s.
/// It will replace the following with generated text:
/// - [Tag]s
/// - [Link]s
/// - [Badge]s
///
/// [GeneratedFile]s may have a different file extensions.
/// e.g. [MarkdownTemplateFile] (with .mdt extension) will typically be translated
/// to MarkDown files (with .md extension) extension.
class GeneratedFile {}

/// Represents a documentation file. This could be a [Template] or an other
/// type of file in the doc folder of a project (e.g. a picture).
class DocumentationFile extends ParentNode implements Comparable {
  /// The documentation file
  final ProjectFilePath sourceFilePath;

  /// The path to where the generated [TemplateFile] needs to be stored
  final ProjectFilePath destinationFilePath;

  /// A uri to the web presentation
  /// null if it does not exits of is unknown
  final Uri? destinationWebUri;

  DocumentationFile({
    required ParentNode parent,
    required this.sourceFilePath,
    required this.destinationFilePath,
    this.destinationWebUri,
  }) : super(parent);

  /// Orders wiki pages first.
  @override
  int compareTo(other) {
    if (this is WikiTemplate) {
      if (other is WikiTemplate) {
        // both are wiki pages so compare names
        return this
            .destinationFilePath
            .path
            .compareTo(other.destinationFilePath.path);
      }
      // this is a wiki page and other is not a wiki page so this comes before
      return -1;
    } else {
      // this is not a wiki page so this comes after
      return 1;
    }
  }
}

/// The [DocumentationModelBuilder] will create the [Template] for each [TemplateFile]
/// The [Template] will put the contents of the [TemplateFile] as [TextNode] in its [children]
/// The [DocumentationParser] will replace this [TextNode] with multiple [Node]s if needed.
/// The [OutputBuilder] converts each [Template] into a [GeneratedFile]
class Template extends DocumentationFile {
  final String title;

  Template({
    required ParentNode parent,
    required ProjectFilePath sourceFilePath,
    required ProjectFilePath destinationFilePath,
    Uri? destinationWebUri,
  })  : title = createTitle(sourceFilePath),
        super(
            parent: parent,
            sourceFilePath: sourceFilePath,
            destinationFilePath: destinationFilePath,
            destinationWebUri: destinationWebUri) {
    children.addAll(_createChildren());
  }

  /// Creates 2 [MarkdownNode]s:
  /// - A Markdown comment text stating that the file was generated.
  /// - The contents of the source file ([TemplateFile]) and puts all text in a [MarkdownText]
  ///
  /// This [MarkdownText] will later be:
  /// - split up in other [TextNode]s
  /// - [Tag] texts will be converted to [Tag] objects by the [TagParser]
  /// - [Link] texts will be converted to [LinkNode] objects by the [LinkParser]
  List<Node> _createChildren() => [
        TextNode(this, thisFileWasGeneratedComment(sourceFilePath)),
        TextNode(this, readSourceFileText(sourceFilePath)),
      ];

  String readSourceFileText(ProjectFilePath sourcePath) =>
      sourcePath.toFile().readAsStringSync();

  String thisFileWasGeneratedComment(ProjectFilePath sourcePath) =>
      '[//]: # (This file was generated from: ${sourcePath.toString()} using the documentation_builder package on: ${DateTime.now()}.)\n';

  /// Orders wiki pages first.
  @override
  int compareTo(other) {
    if (this is WikiTemplate) {
      if (other is WikiTemplate) {
        // both are wiki pages so compare names
        return this
            .destinationFilePath
            .path
            .compareTo(other.destinationFilePath.path);
      }
      // this is a wiki page and other is not a wiki page so this comes before
      return -1;
    } else {
      // this is not a wiki page so this comes after
      return 1;
    }
  }

  hasWebUriAndFileEndsWith(String path) {
    path = path.toLowerCase();
    return destinationWebUri != null &&
        (sourceFilePath.path.toLowerCase().endsWith(path) ||
            destinationFilePath.path.toLowerCase().endsWith(path));
  }

  static final FluentRegex filePath =
      FluentRegex().anyCharacter(Quantity.oneOrMoreTimes()).literal('/');

  static final FluentRegex fileExtension = FluentRegex()
      .literal('.')
      .characterSet(
          CharacterSet().addLetters().addDigits(), Quantity.oneOrMoreTimes())
      .endOfLine();

  static String createTitle(ProjectFilePath sourceFilePath) {
    String fileName = filePath.removeFirst(sourceFilePath.toString());
    String fileNameWithoutExtension = fileExtension.removeFirst(fileName);
    String title = fileNameWithoutExtension.replaceAll('-', ' ');
    return title;
  }
}

abstract class DocumentationFactory<T extends Template> {
  FluentRegex get fileNameExpression;

  bool canCreateFor(String markdownTemplatePath) {
    return fileNameExpression.hasMatch(markdownTemplatePath);
  }

  DocumentationFile createDocument(
      ParentNode parent, ProjectFilePath sourceFilePath);
}

class DocumentationFileFactories extends DelegatingList<DocumentationFactory> {
  DocumentationFileFactories()
      : super([
          ReadMeTemplateFactory(),
          ChangeLogTemplateFactory(),
          ExampleTemplateFactory(),
          WikiTemplateFactory(),
          WikiFileFactory(),
          LicenseFactory(),
        ]);
}

/// A README.md file is typically the first item a visitor will see when visiting
/// your package on https://pub.dev or visiting your code on https://github.com.
///
/// A README.md file typically include information on:
/// - What the project does
/// - Why the project is useful
/// - How to use it
/// - other relevant high level information
///
/// A README.mdt is a [TemplateFile] that is used by the [DocumentationBuilder]
/// to create or override the README.md file in the root of your dart project.
/// The README.mdt file is stored in the doc/template folders in the root of the
/// project
class ReadMeFile extends MarkdownTemplateFile {}

class ReadMeTemplate extends Template {
  ReadMeTemplate(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: ProjectFilePath('README.md'),
          destinationWebUri: PubDevProject().uri,
        );
}

class ReadMeTemplateFactory extends DocumentationFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('readme.mdt').endOfLine().ignoreCase();

  @override
  Template createDocument(ParentNode parent, ProjectFilePath sourceFilePath) =>
      ReadMeTemplate(parent, sourceFilePath);
}

/// A CHANGELOG.md is a log or record of all notable changes made to a project.
/// To support tools that parse CHANGELOG.md, use the following format:
/// - Each version has its own section with a heading.
/// - The version headings are either a chapter (#) or a paragraph (##).
/// - The version heading text contains a package version number, optionally prefixed with “v”.
///
/// A CHANGELOG.mdt is a [TemplateFile] that is used by the [DocumentationBuilder]
/// to create or override the CHANGELOG.md file in the root of your dart project.
///
/// A CHANGELOG.mdt file can contain the [TODO CHANGELOG_TAG] which will generate the
/// versions assuming you are using GitHub and mark very version as a milestone.
/// The CHANGELOG.mdt file is stored in the doc/template folders in the root
/// of the project

class ChangeLogFile extends MarkdownTemplateFile {}

class ChangeLogTemplate extends Template {
  ChangeLogTemplate(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: ProjectFilePath('CHANGELOG.md'),
          destinationWebUri: PubDevProject().changeLogUri,
        );
}

class ChangeLogTemplateFactory extends DocumentationFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('changelog.mdt').endOfLine().ignoreCase();

  @override
  Template createDocument(ParentNode parent, ProjectFilePath sourceFilePath) =>
      ChangeLogTemplate(parent, sourceFilePath);
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [TemplateFile] that is used by the
/// [DocumentationBuilder] to create or override the example.md file in the
/// example folder of your dart project.
/// The example.mdt file is stored in the doc/template folders in the root of
/// the project
class ExampleFile extends MarkdownTemplateFile {}

class ExampleTemplate extends Template {
  ExampleTemplate(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: ProjectFilePath('example/example.md'),
          destinationWebUri: PubDevProject().exampleUri,
        );
}

class ExampleTemplateFactory extends DocumentationFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('/example.mdt').endOfLine().ignoreCase();

  @override
  Template createDocument(ParentNode parent, ProjectFilePath sourceFilePath) =>
      ExampleTemplate(parent, sourceFilePath);
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are [TemplateFile]s.
/// See [Github Wiki pages](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis)
/// for more information.
///
/// Any [TemplateFile] is considered to be a Wiki Template File when:
/// - Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
/// - Its name starts with 2 digits, and has a .mdt extension (e.g.: 02-Getting-Started.mdt)
///
/// Note that spaces are replaced with - in the file name, and vice versa for the title.
///
/// All generated [WikiTemplateFile]s are stored in the ../<project name&gt;.wiki directory (next to your project folder).
/// This directory is a clone of the [GitHub wiki repository](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-or-editing-wiki-pages-locally).
class WikiTemplateFile extends MarkdownTemplateFile {}

class WikiTemplate extends Template {
  WikiTemplate(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: createDestinationFilePath(sourceFilePath),
          destinationWebUri: createDestinationWebUri(sourceFilePath),
        );

  static String destinationDirectoryPath = '../${LocalProject.name}.wiki';

  static ProjectFilePath createDestinationFilePath(
      ProjectFilePath sourceFilePath) {
    String wikiFileName = createFileName(sourceFilePath);
    return ProjectFilePath('$destinationDirectoryPath/$wikiFileName.md',
        isParentPath: true);
  }

  static Uri? createDestinationWebUri(ProjectFilePath sourceFilePath) {
    Uri? wikiUri = GitHubProject().wikiUri;
    if (wikiUri == null) return null;
    return wikiUri.withPathSuffix(createPathSuffix(sourceFilePath));
  }

  static String createFileName(ProjectFilePath sourceFilePath) {
    String? wikiFileName = WikiTemplateFactory()
        .fileNameExpression
        .findCapturedGroups(sourceFilePath.toString())
        .values
        .firstWhere((v) => v != null);
    if (wikiFileName == null) {
      throw ParserWarning('Could not find the file name of: $sourceFilePath');
    }
    return wikiFileName;
  }

  static String createPathSuffix(ProjectFilePath sourceFilePath) =>
      '/' + createFileName(sourceFilePath);
}

class WikiTemplateFactory extends DocumentationFactory {
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
  Template createDocument(ParentNode parent, ProjectFilePath sourceFilePath) =>
      WikiTemplate(parent, sourceFilePath);
}

/// All files in the doc folder that are not a .mdt file (e.g. pictures)
class WikiFile extends DocumentationFile {
  WikiFile(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: createDestinationFilePath(sourceFilePath),
          destinationWebUri: createDestinationWebUri(sourceFilePath),
        );

  static String destinationDirectoryPath = '../${LocalProject.name}.wiki';

  static ProjectFilePath createDestinationFilePath(
      ProjectFilePath sourceFilePath) {
    String wikiFileName = createFileName(sourceFilePath);
    return ProjectFilePath('$destinationDirectoryPath/$wikiFileName',
        isParentPath: true);
  }

  static Uri? createDestinationWebUri(ProjectFilePath sourceFilePath) {
    Uri? wikiUri = GitHubProject().wikiUri;
    if (wikiUri == null) return null;
    return wikiUri.withPathSuffix(createPathSuffix(sourceFilePath));
  }

  static String createFileName(ProjectFilePath sourceFilePath) =>
      File(sourceFilePath.absoluteFilePath).uri.pathSegments.last;

  static String createPathSuffix(ProjectFilePath sourceFilePath) =>
      '/' + createFileName(sourceFilePath);
}

/// Creates [DocumentationFile]s for all files in the doc folder
/// that are not a .mdt file (e.g. pictures)
class WikiFileFactory extends DocumentationFactory {
  @override
  FluentRegex get fileNameExpression => FluentRegex()
      .startOfLine()
      .literal('doc/')
      .anyCharacter(Quantity.oneOrMoreTimes())
      .group(FluentRegex().literal('.mdt'),
          type: GroupType.lookPrecedingAnythingBut())
      .endOfLine()
      .ignoreCase();

  @override
  DocumentationFile createDocument(
          ParentNode parent, ProjectFilePath sourceFilePath) =>
      WikiFile(parent, sourceFilePath);
}

/// Public repositories on GitHub are often used to share open source software.
/// For your repository to truly be open source, you'll need to license it so
/// that others are free to use, change, and distribute the software.
///
/// Public repositories on GitHub are often used to share open source software.
/// For your repository to truly be open source, you'll need to license it so
/// that others are free to use, change, and distribute the software.
///
/// A LICENSE.mdt is a [TemplateFile] that is used by the [DocumentationBuilder]
/// to create or override the LICENSE file in the root of your dart project.
///
/// A LICENSE.mdt file can contain the [MitLicenseTag] which will generate
/// a [MIT License](https://opensource.org/licenses/MIT) with up to date year.

class LicenseFile extends MarkdownTemplateFile {}

class LicenseTemplate extends Template {
  LicenseTemplate(ParentNode parent, ProjectFilePath sourceFilePath)
      : super(
          parent: parent,
          sourceFilePath: sourceFilePath,
          destinationFilePath: ProjectFilePath('LICENSE'),
          destinationWebUri: PubDevProject().licenseUri,
        );
}

class LicenseFactory extends DocumentationFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('/LICENSE.mdt').endOfLine().ignoreCase();

  @override
  Template createDocument(ParentNode parent, ProjectFilePath sourceFilePath) =>
      LicenseTemplate(parent, sourceFilePath);
}
