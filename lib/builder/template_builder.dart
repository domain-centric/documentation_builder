import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// Finds .mdt files, and puts them in the [DocumentationModel]
class MarkdownTemplateBuilder implements Builder {
  /// '.mdt' makes the build_runner run [MarkdownTemplateBuilder] for every file with a .mdt extension
  /// This builder stores the result in the [DocumentationModel] resource  to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        '.mdt': ['dummy.dummy']
      };

  /// For each [MarkdownTemplate] the [MarkdownTemplateBuilder] will:
  /// - try to find a matching [MarkdownTemplateFactory]
  /// - create a [MarkdownTemplate] object that converts the text to [MarkdownText] objects.
  /// - this [MarkdownTemplate] object is than stored inside the [DocumentationModel] to be further processed by other Builders
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var factories = MarkdownTemplateFactories();
    try {
      String markdownTemplatePath = buildStep.inputId.path;
      MarkdownTemplateFactory factory =
          factories.firstWhere((f) => f.canCreateFor(markdownTemplatePath));
      DocumentationModel model =
          await buildStep.fetchResource<DocumentationModel>(resource);
      var markdownPage =
          factory.createMarkdownTemplate(model, buildStep.inputId.path);

      model.add(markdownPage);
    } on Error {
      print('Unknown mark down template file: ${buildStep.inputId.path}');
    }
  }
}

/// [MarkdownTemplateFile]s are files with a .mdt extension that can contain:
/// - [Markdown](https://www.markdownguide.org/cheat-sheet/) text
/// - [Tag]s
/// - [Link]s
/// - [Badge]s
///
/// [MarkdownTemplateFile]s are converted to [GeneratedMarkdownFile]s
class MarkdownTemplateFile {}

/// [GeneratedMarkdownFile]s are files with a .md extension that are generated
/// by the [DocumentationBuilder].
class GeneratedMarkdownFile {}

/// The [MarkdownTemplateBuilder] will create the [MarkdownTemplate] for each [MarkdownTemplateFile]
/// The [MarkdownTemplate] will put the contents of the [MarkdownTemplateFile] as [TextNode] in its [children]
/// The [DocumentationParser] will replace this [TextNode] with multiple [Node]s if needed.
/// The [OutputBuilder] converts each [MarkdownTemplate] into a [GeneratedMarkdownFile]
class MarkdownTemplate extends ParentNode implements Comparable {
  /// The [MarkdownTemplateFile]
  final ProjectFilePath sourceFilePath;

  /// The path to where the generated [MarkdownTemplateFile] needs to be stored
  final ProjectFilePath destinationFilePath;

  /// A uri to the web presentation
  /// null if it does not exits of is unknown
  final Uri? destinationWebUri;

  /// [MarkdownTemplateFactory] that created this [MarkdownTemplate]
  /// to determine its type.
  final MarkdownTemplateFactory factory;

  final String title;

  MarkdownTemplate({
    required this.factory,
    required ParentNode parent,
    required String sourcePath,
    required this.destinationFilePath,
    required this.destinationWebUri,
  })  : sourceFilePath = ProjectFilePath(sourcePath), title=createTitle(sourcePath),
        super(parent) {
    children.addAll(_createChildren());
  }

  /// Creates 2 [MarkdownNode]s:
  /// - A Markdown comment text stating that the file was generated.
  /// - The contents of the source file ([MarkdownTemplateFile]) and puts all text in a [MarkdownText]
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
    if (this.factory is WikiFile) {
      if (other is MarkdownTemplate && other.factory is WikiFile) {
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

  static String createTitle(String path) {
    String fileName = filePath.removeFirst(path);
    String fileNameWithoutExtension = fileExtension.removeFirst(fileName);
    String title = fileNameWithoutExtension.replaceAll('-', ' ');
    return title;
  }
}

abstract class MarkdownTemplateFactory {
  FluentRegex get fileNameExpression;

  ProjectFilePath createDestinationPath(String sourcePath);

  Uri? createDestinationWebUri(String sourceFilePath);

  bool canCreateFor(String markdownTemplatePath) {
    return fileNameExpression.hasMatch(markdownTemplatePath);
  }

  MarkdownTemplate createMarkdownTemplate(
      ParentNode parent, String sourceFilePath) {
    return MarkdownTemplate(
      factory: this,
      parent: parent,
      sourcePath: sourceFilePath,
      destinationFilePath: createDestinationPath(sourceFilePath),
      destinationWebUri: createDestinationWebUri(sourceFilePath),
    );
  }
}

class MarkdownTemplateFactories
    extends DelegatingList<MarkdownTemplateFactory> {
  MarkdownTemplateFactories()
      : super([
          ReadMeFile(),
          ChangeLogFile(),
          ExampleFile(),
          WikiFile(),
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
/// A README.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder]
/// to create or override the README.md file in the root of your dart project.
class ReadMeFile extends MarkdownTemplateFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('readme.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('README.md');

  @override
  Uri? createDestinationWebUri(String sourceFilePath) => PubDevProject().uri;
}

/// A CHANGELOG.md is a log or record of all notable changes made to a project.
/// To support tools that parse CHANGELOG.md, use the following format:
/// - Each version has its own section with a heading.
/// - The version headings are either a chapter (#) or a paragraph (##).
/// - The version heading text contains a package version number, optionally prefixed with “v”.
///
/// A CHANGELOG.mdt is a [MarkdownTemplateFile] that is used by the [DocumentationBuilder]
/// to create or override the CHANGELOG.md file in the root of your dart project.
///
/// A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG] which will generate the
/// versions assuming you are using GitHub and mark very version as a milestone
class ChangeLogFile extends MarkdownTemplateFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('changelog.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('CHANGELOG.md');

  @override
  Uri? createDestinationWebUri(String sourceFilePath) =>
      PubDevProject().changeLogUri;
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [MarkdownTemplateFile] that is used by the
/// [DocumentationBuilder] to create or override the example.md file in the
/// example folder of your dart project.
class ExampleFile extends MarkdownTemplateFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('example.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('example/example.md');

  @override
  Uri? createDestinationWebUri(String sourceFilePath) =>
      PubDevProject().exampleUri;
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are [WikiFile]s.
/// See [Github Wiki pages](TODO Add link) for more information.
///
///
/// Any [MarkdownTemplateFile] is considered to be a [WikiFile] when:
/// - Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
/// - Its name starts with 2 digits, and has a .mdt extension (e.g.: 08-Getting-Started.mdt)
///
/// All generated [WikiFile]s are stored in the doc/<project name&gt;.wiki directory.
/// This directory is a clone of the [GitHub wiki repository](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-or-editing-wiki-pages-locally).
class WikiFile extends MarkdownTemplateFactory {
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
    String wikiFileName = createFileName(sourcePath);
    return ProjectFilePath('doc/${LocalProject.name}.wiki/$wikiFileName.md'); //TODO automatically empty directory (except for .git directory) in an earlier builder
  }

  String createFileName(String sourcePath) {
    String? wikiFileName = fileNameExpression
        .findCapturedGroups(sourcePath)
        .values
        .firstWhere((v) => v != null);
    if (wikiFileName == null) {
      throw ParserWarning('Could not find the file name of: $sourcePath');
    }
    return wikiFileName;
  }

  @override
  Uri? createDestinationWebUri(String sourceFilePath) {
    Uri? wikiUri = GitHubProject().wikiUri;
    if (wikiUri == null) return null;
    return wikiUri.withPathSuffix(createPathSuffix(sourceFilePath));
  }

  String createPathSuffix(String sourceFilePath) =>
      '/' + createFileName(sourceFilePath);
}

//TODO LicenseFactory + LicenseTags + Year tag
