import 'dart:io';

import 'package:resource_portable/resource.dart';
import 'package:template_engine/template_engine.dart';

final gitHubWorkflowPublishWiki = SetupTemplate(
  '.github/workflows/publish-wiki.yml',
);

/// All available [SetupTemplate]s.
final templates = <SetupTemplate>[
  SetupTemplate('doc/template/CHANGELOG.md.template'),
  SetupTemplate('doc/template/LICENSE.md.template'),
  SetupTemplate('doc/template/README.md.template'),
  SetupTemplate('doc/template/doc/wiki/1-Features.md.template'),
  SetupTemplate('doc/template/doc/wiki/2-Getting-Started.md.template'),
  SetupTemplate('doc/template/doc/wiki/3-Usage.md.template'),
  SetupTemplate('doc/template/doc/wiki/4-Examples.md.template'),
  SetupTemplate('doc/template/doc/wiki/Home.md.template'),
  SetupTemplate('doc/template/doc/wiki/package.jpg'),
  SetupTemplate('doc/template/example/example.md.template'),
];

/// A [Template] for setting up the project with the [documentation_builder] CLI.
/// This template is used to create the necessary files and configurations
/// The [Template] is stored inside the package, updated by the [CliTemplateEngine]
/// and stored in the project that is been setup.
class SetupTemplate extends Template {
  late Resource input;
  late File output;
  SetupTemplate(String path) {
    input = Resource('package:documentation_builder/src/cli/template/$path');
    output = File(path);
    super.source = input.uri.toString();
    super.sourceTitle = source;
  }

  @override
  Future<String> get text async => await input.readAsString();

  Future<bool> get isTextFile async {
    try {
      await text;
      return true;
    } catch (e) {
      return !e.toString().contains('Failed to decode data using encoding');
    }
  }
}
