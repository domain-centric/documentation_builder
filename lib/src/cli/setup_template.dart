import 'dart:convert';
import 'dart:io';

import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';

const String _cliTemplates = 'cli_templates';

Future<List<SetupTemplate>> createGitHubWorkflowTemplates(
  GitHubProject gitHubProject,
) async => await findAllCliTemplatesFromGitHub(
  gitHubProject,
  '$_cliTemplates/.github',
);

Future<List<SetupTemplate>> createDocumentationTemplates(
  GitHubProject gitHubProject,
) async =>
    await findAllCliTemplatesFromGitHub(gitHubProject, '$_cliTemplates/doc');

Future<List<SetupTemplate>> findAllCliTemplatesFromGitHub(
  GitHubProject gitHubProject,
  String path,
) async {
  final List<SetupTemplate> templates = <SetupTemplate>[];
  final List<Uri> gitHubResourceUris = await gitHubProject.findFilesInPath(
    path,
  );

  for (final Uri gitHubResourceUri in gitHubResourceUris) {
    var input = gitHubResourceUri;
    var index =
        gitHubResourceUri.toString().indexOf(_cliTemplates) +
        _cliTemplates.length +
        1;
    var outputPath = gitHubResourceUri.toString().substring(index);
    var output = File(outputPath);
    templates.add(SetupTemplate(input: input, output: output));
  }

  return templates;
}

/// A [Template] for setting up the project with the [documentation_builder] CLI.
/// This template is used to create the necessary files and configurations
/// The [Template] is processed by the [SetupCommand]:
/// - read from github.com
/// - parsed and rendered by the [CliTemplateEngine]
/// - stored in the project that is been setup.
class SetupTemplate extends Template {
  final Uri input;
  final File output;
  SetupTemplate({required this.input, required this.output}) {
    super.source = input.toString();
    super.sourceTitle = source;
  }

  @override
  Future<String> get text async {
    if (input.isScheme('https')) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(input);
        final response = await request.close();
        if (response.statusCode == 200) {
          return await response.transform(const Utf8Decoder()).join();
        } else {
          throw Exception(
            'Failed to load template from $input (status: ${response.statusCode})',
          );
        }
      } finally {
        client.close();
      }
    } else {
      return await File.fromUri(input).readAsString();
    }
  }

  Future<bool> get isTextFile async {
    try {
      await text;
      return true;
    } catch (e) {
      return !e.toString().contains('Failed to decode data using encoding');
    }
  }
}
