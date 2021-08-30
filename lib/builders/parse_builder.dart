import 'dart:async';

import 'package:build/build.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/parser/documentation_parser.dart';
import 'package:documentation_builder/parser/parser.dart';

/// Lets the [DocumentationParser] parse the [DocumentationModel].
class ParseBuilder implements Builder {

  /// '$lib$' makes the build_runner run [ParseBuilder] only one time (not for each individual file)
  /// This builder stores the result in the [DocumentationModel] resource to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions =>
      {
        r'$lib$': ['dummy.dummy']
      };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    await buildStep.fetchResource<DocumentationModel>(resource);
    try {
      DocumentationModel model =
      await buildStep.fetchResource<DocumentationModel>(resource);
      model.buildStep=buildStep;
      DocumentationParser().parse(model);
    } on ParserWarning catch (parseWarning) {
      showWarningsInConsole(parseWarning);
    }
  }

  void showWarningsInConsole(ParserWarning parseWarning) {
    print(parseWarning.toString());
  }
}

