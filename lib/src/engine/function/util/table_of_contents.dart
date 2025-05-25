import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:documentation_builder/documentation_builder.dart';
import 'package:petitparser/petitparser.dart';
import 'package:template_engine/template_engine.dart';

class TableOfContentsFactory {
  Future<String> createMarkDown({
    required RenderContext renderContext,
    required String relativePath,
    required bool includeFileLink,
    required bool gitHubWiki,
  }) async {
    var titleLinks = <TitleLink>[];
    var path = normalizePathSeparators(
      "${LocalProject.directory.path}/$relativePath",
      Platform.pathSeparator,
    );
    var builder = BuilderVariable.of(renderContext);
    var files = findFiles(path);
    for (var file in files) {
      var relativeInputPath = createRelativePath(file);
      var input = AssetId(LocalProject.name, relativeInputPath);
      var outputs = expectedOutputs(builder, input);
      if (outputs.isEmpty) {
        continue;
      }
      var outputFileName = outputs.first.pathSegments.last;
      if (includeFileLink) {
        var titleLink = TitleLink.fromFileName(
          relativePath: outputFileName,
          removeMdExtension: gitHubWiki,
        );
        titleLinks.add(titleLink);
      }
      String markDown = await parseAndRender(file, renderContext);
      var newTitleLinks = findTitles(
        outputFileName: outputFileName,
        markDown: markDown,
        removeMdExtension: gitHubWiki,
      );
      newTitleLinks = toListWithoutLevelGabs(newTitleLinks);
      titleLinks.addAll(newTitleLinks);
    }
    return titleLinks.map((t) => t.markDown).join(newLine);
  }

  Future<String> parseAndRender(File file, RenderContext renderContext) async {
    try {
      var template = FileTemplate(file);
      var parseResult = await engine.parseTemplate(template);
      var renderResult = await engine.render(
        parseResult,
        renderContext.variables,
      );
      var markDown = renderResult.text;
      return markDown;
    } on Exception {
      // return nothing if we fail, e.g. when the file is an image and not a text;
      return '';
    }
  }

  static final engine = _createEngine();

  /// returns a list of files based on source.
  /// [path]  is a relative project path to a template file (e.g.: doc/template/README.md.template) or a folder with template files (e.g.: doc/template/wiki)
  List<File> findFiles(String path) {
    var entityType = FileSystemEntity.typeSync(path);

    if (entityType == FileSystemEntityType.file) {
      return [File(path)];
    } else if (entityType == FileSystemEntityType.directory) {
      return filesInDirectory(Directory(path));
    } else {
      throw ArgumentError('$path does not exist', 'path');
    }
  }

  List<File> filesInDirectory(Directory directory) {
    var files = <File>[];

    var entities = directory.listSync(recursive: false, followLinks: false);
    for (var entity in entities) {
      if (entity is File) {
        files.add(entity);
      }
    }
    if (files.isEmpty) {
      throw ArgumentError('$directory does not contain files', 'path');
    }
    return files;
  }

  List<TitleLink> findTitles({
    required String outputFileName,
    required String markDown,
    required bool removeMdExtension,
  }) {
    var parser = markdownTitleParser();
    var matches = parser.allMatches(
      '\n\r\n$markDown',
    ); // \n\r\n are added to ensure the parser also matched the first line
    var titleLinks = <TitleLink>[];
    for (var match in matches) {
      var titleLink = TitleLink(
        relativePath: removeMdExtension
            ? outputFileName.replaceFirst(RegExp(r'\.md$'), '')
            : outputFileName,
        title: match.title,
        level: match.hashes.length,
      );
      titleLinks.add(titleLink);
    }
    return titleLinks;
  }

  static DocumentationTemplateEngine _createEngine() {
    var engine = DocumentationTemplateEngine();
    replaceTocFunctionToPreventRoundTrips(engine);
    return engine;
  }

  static void replaceTocFunctionToPreventRoundTrips(
    DocumentationTemplateEngine engine,
  ) {
    for (var functionGroup in engine.functionGroups) {
      for (var function in functionGroup) {
        if (function is TableOfContents) {
          functionGroup.remove(function);
          functionGroup.add(TableOfContentsDummy());
        }
      }
    }
  }

  String createRelativePath(File file) {
    var nativeRelativePath = file.path.replaceFirst(
      '${LocalProject.directory.path}${Platform.pathSeparator}',
      '',
    );
    var normalizedRelativePath = normalizePathSeparators(
      nativeRelativePath,
      '/',
    );
    return normalizedRelativePath;
  }

  List<TitleLink> toListWithoutLevelGabs(List<TitleLink> titleLinks) {
    if (titleLinks.isEmpty) {
      return [];
    }
    var newTitleLinks = <TitleLink>[];
    int perviousOldLevel = titleLinks.first.level;
    for (var titleLink in titleLinks) {
      var currentOldLevel = titleLink.level;
      var perviousNewLevel = newTitleLinks.isEmpty
          ? 1
          : newTitleLinks.last.level;
      var newLevel = _newLevel(
        currentOldLevel,
        perviousOldLevel,
        perviousNewLevel,
      );
      var newTitleLink = titleLink.copyWith(level: newLevel);
      newTitleLinks.add(newTitleLink);
      perviousOldLevel = currentOldLevel;
    }
    return newTitleLinks;
  }

  int _newLevel(
    int currentOldLevel,
    int perviousOldLevel,
    int perviousNewLevel,
  ) {
    if (currentOldLevel == 0) {
      // old level is 0 is the root level
      // all levels must start with 1
      return 1;
    }
    if (currentOldLevel < perviousOldLevel) {
      // reduce the level, but not below 2
      return max(perviousNewLevel - 1, 2);
    }
    if (currentOldLevel == perviousOldLevel) {
      // keep the level
      return perviousNewLevel;
    }
    //currentOldLevel > perviousOldLevel
    // increase the level
    return perviousNewLevel + 1;
  }
}

/// dummy function to prevent round trips.
class TableOfContentsDummy extends ExpressionFunction {
  TableOfContentsDummy()
    : super(
        name: TableOfContents.nameId,
        function: (position, renderContext, parameters) async => '',
      );
}

class TitleLink {
  final String relativePath;
  final String title;
  // normally 1-3
  final int level;
  final String fragment;

  TitleLink({
    required this.relativePath,
    required this.title,
    required this.level,
  }) : fragment = createFragmentFromTitle(title);

  TitleLink.fromFileName({
    required String relativePath,
    required bool removeMdExtension,
  }) : title = toBold(createTitleFromRelativePath(relativePath)),
       relativePath = removeMdExtension
           ? relativePath.replaceFirst(RegExp(r'\.md$'), '')
           : relativePath,
       level = 0,
       fragment = '';

  /// Markdown will be translated to HTML by converters.
  /// These normally add a anchor or id to a title so that they can be called with a Uri fragment, e.g.:
  /// Markdown: # My Awesome Title
  /// Html: <h1 id="my-awesome-title">My Awesome Title</h1>
  /// This allows you to link directly to the heading like so: https://example.com/page#my-awesome-title
  /// How the id is generated:
  /// * Lowercased
  /// * Spaces replaced with hyphens
  /// * Special characters removed or encoded (depending on the processor)
  static String createFragmentFromTitle(String title) => title
      .toLowerCase() // Convert to lowercase
      .trim() // Trim leading/trailing whitespace
      .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
      .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
      .replaceAll(RegExp(r'-+'), '-'); // Collapse multiple hyphens

  late String indentation = '  ' * (level);

  late String bullet = '* ';

  late String markDown =
      '$indentation$bullet[$title]($relativePath${fragment.isNotEmpty ? "#$fragment" : ""})';

  static String toBold(String markdown) => '**$markdown**';

  static String createTitleFromRelativePath(String relativePath) => relativePath
      .trim() // Trim leading/trailing whitespace
      .replaceAll('-', ' ') // replace hyphens with spaces
      .replaceAll('_', ' ') // replace under scores with spaces
      .replaceAll('  ', ' ') // replace double spaces with single space
      .replaceFirst(RegExp(r'\..*'), ''); // remove the file extension

  TitleLink copyWith({required int level}) =>
      TitleLink(relativePath: relativePath, title: title, level: level);
}

Parser<({String hashes, String title})> markdownTitleParser() {
  final Parser<String> newLine = (string('\n\r') | char('\n')).flatten();
  final Parser<String> hash = char('#');
  final Parser<String> hashes = hash.plus().flatten(); // One or more #
  final Parser<String> optionalWhiteSpace = anyOf(
    " \t",
  ).star().flatten(); // Zero or more non-newline whitespaces
  final Parser<String> whitespace = anyOf(
    " \t",
  ).plus().flatten(); // One or more none newline whitespace
  final Parser<String> titleText = any().starLazy(newline()).flatten();
  return SequenceParser([
    newLine,
    optionalWhiteSpace,
    hashes,
    whitespace,
    titleText,
  ]).map((values) => (hashes: values[2], title: values[4]));
}
