// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/documentation_builder.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart'
    as p;
import 'package:template_engine/template_engine.dart';

/// Resolves the [LibraryElement] for the given [dartFile].
Future<LibraryElement> resolveLibrary(
  RenderContext context,
  p.ProjectFilePath2 dartFile,
) async {
  var buildStep = BuildStepVariable.of(context);
  var libraryCache = LibraryCacheVariable.of(context);
  if (libraryCache.containsKey(dartFile)) {
    return libraryCache[dartFile]!;
  }

  var resolver = buildStep.resolver;
  var assetId = AssetId(LocalProject.name, dartFile.relativePath);
  var library = await resolver.libraryFor(assetId);
  libraryCache[dartFile] = library;
  return library;
}

/// Finds a Dart member element by its [path]
/// in the given [element] so we do not need a visitor.
Element? findElementRecursively(Element element, p.DartMemberPath path) {
  if (element.displayName == path.first && path.length == 1) {
    return element;
  }
  if (element.displayName.isNotEmpty) {
    path = path.withoutParent();
  }
  if (path.isEmpty) {
    return null;
  }
  for (var child in element.children) {
    var found = findElementRecursively(child, path);
    if (found != null) {
      return found;
    }
  }
  return null;
}

void validateIfMemberFound(Element? foundElement, p.SourcePath path) {
  if (foundElement == null) {
    throw ArgumentError(
      'Dart member: ${path.dartLibraryMemberPath} not found in: ${path.projectFilePath}',
    );
  }
}
