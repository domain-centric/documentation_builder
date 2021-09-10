import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/project/github_project.dart';
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
      var markdownPage = factory.createMarkdownPage(model, buildStep.inputId.path);

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
class MarkdownTemplate extends ParentNode {

  /// The [MarkdownTemplateFile]
  final ProjectFilePath sourceFilePath;

  /// The path to where the generated [MarkdownTemplateFile] needs to be stored
  final ProjectFilePath destinationFilePath;

  /// A uri to the web presentation
  /// null if it does not exits of is unknown
  final Uri? destinationWebUri;

  MarkdownTemplate({
    required ParentNode parent,
    required String sourcePath,
    required this.destinationFilePath,
    required this.destinationWebUri,
  })  : sourceFilePath= ProjectFilePath(sourcePath),
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

}

abstract class MarkdownTemplateFactory {
  FluentRegex get fileNameExpression;

  ProjectFilePath createDestinationPath(String sourcePath);

  Uri? createDestinationWebUri(String sourceFilePath);

  bool canCreateFor(String markdownTemplatePath) {
    return fileNameExpression.hasMatch(markdownTemplatePath);
  }

  MarkdownTemplate createMarkdownPage(ParentNode parent, String sourceFilePath) {
    return MarkdownTemplate(
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
    ReadMeFactory(),
    ChangeLogFactory(),
    ExampleFactory(),
    WikiFactory(),
  ]);
}



/// A README.md file is tippacally the first item a visitor will see when visiting
/// your package on https://pub.dev or visiting your code on https://github.com.
///
/// A README.md file typically include information on:
/// - What the project does
/// - Why the project is useful
/// - How to use it
/// - other relevant high level information
///
/// A README.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder]
/// to create or override the README.md file in the root of your dart project.
class ReadMeFactory extends MarkdownTemplateFactory {
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
/// A CHANGELOG.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder]
/// to create or override the CHANGELOG.md file in the root of your dart project.
///
/// A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG] which will generate the
/// versions assuming you are using GitHub and mark very version as a milestone
class ChangeLogFactory extends MarkdownTemplateFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('changelog.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('CHANGELOG.md');

  @override
  Uri? createDestinationWebUri(String sourceFilePath) => PubDevProject().changeLogUri;
}

/// Your Dart/Flutter project can have an example.md file
/// A example.mdt is a [MarkdownTemplate] that is used by the
/// [DocumentationBuilder] to create or override the example.md file in the
/// example folder of your dart project.
class ExampleFactory extends MarkdownTemplateFactory {
  @override
  FluentRegex get fileNameExpression =>
      FluentRegex().literal('example.mdt').endOfLine().ignoreCase();

  @override
  ProjectFilePath createDestinationPath(String sourcePath) =>
      ProjectFilePath('example/example.md');

  @override
  Uri? createDestinationWebUri(String sourceFilePath) => PubDevProject().exampleUri;
}

/// Project's that are stored in [Github](https://github.com/) can have wiki pages.
/// [Github](https://github.com/) wiki pages are markdown files.
/// See [Github Wiki pages](TODO Add link) for more information.
///
///
/// Any [MarkdownTemplate] is considered to be a [WikiMarkdownTemplateFile] when:
/// - Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
/// - Its name starts with 2 digits, and has a .mdt extension (e.g.: 07-Getting-Started.mdt)
class WikiFactory extends MarkdownTemplateFactory {
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
    return ProjectFilePath('doc/wiki/$wikiFileName.md');
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
    Uri? wikiUri=GitHubProject().wikiUri;
    if (wikiUri==null) return null;
    return wikiUri.withPathSuffix(createPathSuffix(sourceFilePath));
  }

  String createPathSuffix(String sourceFilePath) => '/'+createFileName(sourceFilePath);


}


//TODO LicenseFactory + LicenseTags + Year tag
