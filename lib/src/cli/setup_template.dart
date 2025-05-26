import 'dart:io';

import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';

class SetupTemplateFactory {
  final List<SetupTemplate> gitHubWorkflowTemplates;
  // FIXME remove:
  // SetupTemplate(
  //   '.github/workflows/publish-wiki.yml',
  // );
  final List<SetupTemplate> documentationTemplates;

  static var id = 'setupTemplateFactory';
  // FIXME remove:
  // <SetupTemplate>[
  //   SetupTemplate('doc/template/CHANGELOG.md.template'),
  //   SetupTemplate('doc/template/LICENSE.md.template'),
  //   SetupTemplate('doc/template/README.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/1-Features.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/2-Getting-Started.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/3-Usage.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/4-Examples.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/Home.md.template'),
  //   SetupTemplate('doc/template/doc/wiki/package.jpg'),
  //   SetupTemplate('doc/template/example/example.md.template'),
  // ];
  SetupTemplateFactory._({
    required this.gitHubWorkflowTemplates,
    required this.documentationTemplates,
  });

  static Future<SetupTemplateFactory> create(GitHubProject gitHubProject) async {
    var gitHubWorkflowTemplates = await findAllCliTemplatesFromGitHub(
      gitHubProject,
      'cli_templates/.github',
    );
    var documentationTemplates = await findAllCliTemplatesFromGitHub(
      gitHubProject,
      'cli_templates/doc',
    );
    return SetupTemplateFactory._(
      gitHubWorkflowTemplates: gitHubWorkflowTemplates,
      documentationTemplates: documentationTemplates,
    );
  }

  static Future<List<SetupTemplate>> findAllCliTemplatesFromGitHub(
    GitHubProject gitHubProject,
    String path,
  ) async {
    final List<SetupTemplate> templates = <SetupTemplate>[];
    final List<Uri> gitHubResourceUris = await gitHubProject.findFilesInPath(
      path,
    );

    for (final Uri gitHubResourceUri in gitHubResourceUris) {
      var input = File.fromUri(gitHubResourceUri);
      var outputPath = gitHubResourceUri
          .toString(); //FIXME remove first part of the path
      var output = File(outputPath);
      templates.add(SetupTemplate(input: input, output: output));
    }

    return templates;
  }

  static SetupTemplateFactory of(VariableMap variables) =>
      variables[id] as SetupTemplateFactory;
}

/// A [Template] for setting up the project with the [documentation_builder] CLI.
/// This template is used to create the necessary files and configurations
/// The [Template] is processed by the [SetupCommand]:
/// - read from github.com
/// - parsed and rendered by the [CliTemplateEngine]
/// - stored in the project that is been setup.
class SetupTemplate extends Template {
  final File input;
  final File output;
  SetupTemplate({required this.input, required this.output}) {
    super.source = input.toString();
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
