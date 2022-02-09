import 'dart:async';

import 'package:build/build.dart';
import '../generic/documentation_model.dart';
import '../generic/element.dart';
import '../generic/paths.dart';

/// Finds .dart files, find all the [DartCodePath]s for its members and puts them in the [DocumentationModel]
class DartCodePathBuilder implements Builder {
  /// '.dart' makes the build_runner run [MarkdownTemplateBuilder] for every file with a .dart extension
  /// This builder stores the result in the [DocumentationModel] resource  to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['dummy.dummy']
      };

  /// For each Dart file the [DartCodePathBuilder] will:
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    var library = await buildStep.inputLibrary;
    DartFilePath path = DartFilePath(buildStep.inputId.path);
    DartCodePathFinder visitor = DartCodePathFinder(path);
    library.visitChildren(visitor);
    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
    model.dartCodePaths.addAll(visitor.foundPaths);
  }
}
