import 'dart:async';

import 'package:build/build.dart';
import 'package:logging/logging.dart';

import '../generic/documentation_model.dart';
import '../parser/documentation_parser.dart';

/// Lets the [DocumentationParser] parse the [DocumentationModel].
class ParseBuilder implements Builder {
  /// '$lib$' makes the build_runner run [ParseBuilder] only one time (not for each individual file)
  /// This builder stores the result in the [DocumentationModel] resource to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['dummy.dummy']
      };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    await buildStep.fetchResource<DocumentationModel>(resource);
    try {
      DocumentationModel model =
          await buildStep.fetchResource<DocumentationModel>(resource);
      model.buildStep = buildStep;
      await DocumentationParser().parse(model);
    } catch (e, stackTrace) {
      log.log(Level.SEVERE, e, stackTrace);
    }
  }
}
