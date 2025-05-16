import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:documentation_builder/documentation_builder.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/generator.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:petitparser/petitparser.dart';
import 'package:template_engine/template_engine.dart';

class TableOfContentsFactory {
  createMarkDown(RenderContext renderContext, String relativePath,
      bool includeFileLink) async {
    try {
      var titleLinks = <TitleLink>[];
      var path = convertSeparators(
          "${LocalProject.directory.path}/$relativePath",
          Platform.pathSeparator);
      var builder = BuilderVariable.of(renderContext);
      var files = findFiles(path);
      for (var file in files) {
        var relativeInputPath = createRelativePath(file);
        var input = AssetId(LocalProject.name, relativeInputPath);
        var outputs = await expectedOutputs(builder, input);
        if (outputs.isEmpty) {
          continue;
        }
        var outputFileName = outputs.first.pathSegments.last;
        if (includeFileLink) {
          var titleLink = TitleLink.fromFileName(outputFileName);
          titleLinks.add(titleLink);
        }
        String markDown = await parseAndRender(file, renderContext);
        var newTitleLinks =
            findTitles(outputFileName: outputFileName, markDown: markDown);
        newTitleLinks = toListWithoutLevelGabs(newTitleLinks);
        titleLinks.addAll(newTitleLinks);
      }
      return titleLinks.map((t) => t.markDown).join(newLine);
    } on Exception catch (e, s) {
      log.warning('failed $e $s');
    }
  }

  Future<String> parseAndRender(File file, RenderContext renderContext) async {
    try {
      var template = FileTemplate(file);
      var parseResult = await engine.parseTemplate(template);
      var renderResult =
          await engine.render(parseResult, renderContext.variables);
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

  List<TitleLink> findTitles(
      {required String outputFileName, required String markDown}) {
    var parser = _markdownTitleParser();
    markDown =
        newLine + markDown; // hack to ensure we find a title on the first line
    var matches = parser.allMatches(markDown);
    var titleLinks = <TitleLink>[];
    for (var match in matches) {
      var titleLink = TitleLink(
          relativePath: outputFileName,
          title: match.title,
          level: match.hashes.length);
      titleLinks.add(titleLink);
    }
    return titleLinks;
  }

  convertSeparators(String path, String pathSeparator) =>
      path.replaceAll('\\', pathSeparator).replaceAll('/', pathSeparator);

  static DocumentationTemplateEngine _createEngine() {
    var engine = DocumentationTemplateEngine();
    replaceTocFunctionToPreventRoundTrips(engine);
    return engine;
  }

  static void replaceTocFunctionToPreventRoundTrips(
      DocumentationTemplateEngine engine) {
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
        '${LocalProject.directory.path}${Platform.pathSeparator}', '');
    var normalizedRelativePath = convertSeparators(nativeRelativePath, '/');
    return normalizedRelativePath;
  }

  List<TitleLink> toListWithoutLevelGabs(List<TitleLink> titleLinks) {
    var tree = createTitleNodes(titleLinks);
    return tree
        .map((titleNode) => titleNode.createTitleLinks(1))
        .flattened
        .toList();
  }

  List<TitleNode> createTitleNodes(List<TitleLink> titleLinks) {
    var root = <TitleNode>[];
    TitleLink? current;
    var children = <TitleLink>[];
    for (var titleLink in titleLinks) {
      if (current == null) {
        current = titleLink;
      } else {
        if (titleLink.level <= current.level) {
          var titleNode = createTitleNode(current, children);
          root.add(titleNode);
          current = titleLink;
          children.clear();
        } else {
          children.add(titleLink);
        }
      }
    }
    if (current == null) return [];
    var titleNode = createTitleNode(current, children);
    root.add(titleNode);
    return root;
  }

  TitleNode createTitleNode(TitleLink parent, List<TitleLink> children) =>
      TitleNode(
          relativePath: parent.relativePath,
          title: parent.title,
          fragment: parent.fragment,
          children: createTitleNodes(children));
}

class TitleNode {
  final String relativePath;
  final String title;
  final String fragment;
  final List<TitleNode> children;

  TitleNode(
      {required this.relativePath,
      required this.title,
      required this.fragment,
      required this.children});

  List<TitleLink> createTitleLinks(int level) {
    var links = <TitleLink>[];
    links.add(createTitleLink(level));
    links.addAll(children.map((c) => c.createTitleLink(level + 1)));
    return links;
  }

  TitleLink createTitleLink(int level) =>
      TitleLink(relativePath: relativePath, title: title, level: level);
}

/// dummy function to prevent round trips.
class TableOfContentsDummy extends ExpressionFunction {
  TableOfContentsDummy()
      : super(
            name: TableOfContents.nameId,
            function: (position, renderContext, parameters) async => '');
}

///TODO move to test
void main() {
  final markdownText = '''
# Title One
Some paragraph text.
## Subtitle One
### Sub-subtitle
Another paragraph.
# Another Title
This is a hashtag: #, not a title
''';

  var parser = _markdownTitleParser();
  var matches = parser.allMatches(markdownText);
  for (var match in matches) {
    print('title: ${match.title}, level: ${match.hashes.length}');
  }
}

class TitleLink {
  final String relativePath;
  final String title;
  // normally 1-3
  final int level;
  final String fragment;

  TitleLink(
      {required this.relativePath, required this.title, required this.level})
      : fragment = createFragmentFromTitle(title);

  TitleLink.fromFileName(this.relativePath)
      : title = toBold(createTitleFromRelativePath(relativePath)),
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
      .replaceFirst(RegExp(r'\..*'), ''); // remove file extensions
}

Parser<({String hashes, String title})> _markdownTitleParser() {
  final Parser<String> hash = char('#');
  final Parser<String> hashes = hash.plus().flatten(); // One or more #
  final Parser<String> optionalWhiteSpace =
      anyOf(" \t").star().flatten(); // One or more non-newline whitespace
  final Parser<String> whitespace =
      anyOf(" \t").plus().flatten(); // One or more non-newline whitespace
  final Parser<String> titleText = any().starLazy(newline()).flatten().trim();
  return SequenceParser([
    newline(),
    optionalWhiteSpace,
    hashes,
    whitespace,
    titleText,
  ]).map((values) => (hashes: values[2], title: values[4]));
}
