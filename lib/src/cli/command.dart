import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';
import 'package:collection/collection.dart';
import 'package:process_run/shell.dart';
import 'package:yaml_magic/yaml_magic.dart';

abstract class Command {
  String get name;
  String get description;
  Future<void> run();
}

class Commands extends UnmodifiableListView<Command> {
  Commands() : super([HelpCommand(), BuildCommand(), SetupCommand()]);

  /// Returns a string with all available commands and their descriptions.
  String get availableCommandsText {
    var buffer = StringBuffer('Available commands:\n');
    int firstColumnWidth = map(
      (command) => command.name.length,
    ).reduce((a, b) => max(a, b));
    for (var command in this) {
      var name = command.name.toLowerCase();
      for (var descriptionLine in command.description.trim().split('\n')) {
        buffer.write(
          '  ${name.padRight(firstColumnWidth)}  $descriptionLine\n',
        );
        name = '';
      }
    }
    return buffer.toString();
  }

  /// Finds a command by its name in the provided list of arguments.
  CommandLineResult? find(List<String> args) {
    if (args.isEmpty) {
      return CommandLineFailure('No command argument provided.');
    }
    if (args.length > 1) {
      return CommandLineFailure('Too many arguments.');
    }
    final commandName = args[0].toLowerCase();
    final command = Commands().firstWhereOrNull(
      (cmd) => cmd.name.toLowerCase() == commandName,
    );
    if (command == null) {
      return CommandLineFailure('Command not found. ');
    }

    return CommandLineSuccess(command);
  }
}

/// Represents the result of [Commands.find].
abstract class CommandLineResult {}

class CommandLineFailure implements CommandLineResult {
  final String error;
  CommandLineFailure(String error)
    : error = '$error\n${Commands().availableCommandsText}';
}

class CommandLineSuccess implements CommandLineResult {
  final Command command;
  CommandLineSuccess(this.command);
}

/// A command that shows the available commands.
class HelpCommand extends Command {
  @override
  final String name = 'help';

  @override
  final String description = 'Shows available commands.';

  @override
  Future<void> run() async {
    print(Commands().availableCommandsText);
  }
}

/// Builds the documentation files from template files by starting build_runner build.
class BuildCommand extends Command {
  @override
  final String name = 'build';

  @override
  final String description =
      'Builds the documentation files from template files by starting build_runner build.';

  @override
  Future<void> run() async {
    var shell = Shell();
    await shell.run(
      "dart run build_runner build --delete-conflicting-outputs --verbose",
    );
  }
}

/// Sets up a project to use the documentation_builder package.
class SetupCommand extends Command {
  final engine = CliTemplateEngine();
  @override
  final String name = 'setup';

  @override
  final String description =
      'Sets up a project to use the documentation_builder:\n'
      '- Adds build_runner as dev dependency if needed\n'
      '- Adds documentation_builder as dev dependency if needed\n'
      '- Adds or updates build.yaml\n'
      '- Adds template files if needed\n'
      '- Adds github publish-wiki workflow if needed';

  @override
  Future<void> run() async {
    var variables = await _createVariables();

    var yamlMap = await readPubSpecYaml();

    await addBuildRunnerDependencyIfNeeded(yamlMap);

    await addDocumentationBuilderDependencyIfNeeded(yamlMap);

    await addOrUpdateBuildYaml();

    await addDocumentationTemplateFilesIfNeeded(variables);

    await addGitHubWorkflowFilesIfNeeded(variables);
  }

  Future<void> addDocumentationBuilderDependencyIfNeeded(YamlMagic yaml) async {
    if (hasDependency(yaml, documentationBuilder)) {
      print('$documentationBuilder is already a dev dependency.');
      return;
    }
    if (packageIsDocumentationBuilder()) {
      print(
        '$documentationBuilder can not be added as dev dependency to itself.',
      );
      return;
    }
    print('Adding $documentationBuilder as dev dependency...');
    await addDevDependency(documentationBuilder);
  }

  bool packageIsDocumentationBuilder() =>
      LocalProject.name == 'documentation_builder';

  Future<void> addBuildRunnerDependencyIfNeeded(YamlMagic yaml) async {
    if (hasDependency(yaml, buildRunner)) {
      print('$buildRunner is already a dev dependency.');
    } else {
      print('Adding $buildRunner as dev dependency...');
      await addDevDependency(buildRunner);
    }
  }

  Future<YamlMagic> readPubSpecYaml() async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print(
        'pubspec.yaml not found. Run this command in the root of your project.',
      );
      exit(65);
    }
    final yaml = await pubspecFile.readAsString();
    final yamlMagic = parseYaml(yamlString: yaml, sourcePath: pubspecFile.path);
    return yamlMagic;
  }

  static const String buildRunner = 'build_runner';
  static const String documentationBuilder = 'documentation_builder';
  static final Uri _documentationBuilderGitHubUri = Uri.https(
    'github.com',
    'domain-centric/documentation_builder',
  );

  Future<void> addDocumentationTemplateFilesIfNeeded(
    VariableMap variables,
  ) async {
    if (projectHasDocumentationTemplateFiles()) {
      print('Project already has documentation template files.');
    } else {
      // We need a GitHubProject for documentation_builder not the local project!
      var gitHubProject = await GitHubProject.createForUri(
        _documentationBuilderGitHubUri,
      );
      var documentationTemplates = await createDocumentationTemplates(
        gitHubProject,
      );
      for (var template in documentationTemplates) {
        await addFileIfNeeded(template, variables);
      }
    }
  }

  /// Checks if the project already has template files in the expected output locations.
  bool projectHasDocumentationTemplateFiles() {
    var templateDir = Directory('doc/template');
    if (!templateDir.existsSync()) {
      return false;
    }

    final hasTemplateFiles = templateDir
        .listSync(recursive: true)
        .whereType<File>()
        .any((file) => file.path.endsWith('.template'));

    return hasTemplateFiles;
  }

  Future<void> addGitHubWorkflowFilesIfNeeded(VariableMap variables) async {
    if (hasGitWorkflowFiles()) {
      print('Project already has GitHub Workflow files.');
    } else {
      // We need a GitHubProject for documentation_builder not the local project!
      var gitHubProject = await GitHubProject.createForUri(
        _documentationBuilderGitHubUri,
      );
      var workflowTemplates = await createGitHubWorkflowTemplates(
        gitHubProject,
      );
      for (var template in workflowTemplates) {
        await addFileIfNeeded(template, variables);
      }
    }
  }

  Future<void> addFileIfNeeded(
    SetupTemplate template,
    VariableMap variables,
  ) async {
    print('Adding ${template.output}...');
    if (await template.isTextFile) {
      await parseRenderAndWrite(template, variables);
    } else {
      await copyFile(template);
    }
  }

  Future<VariableMap> _createVariables() async {
    var variables = VariableMap();
    try {
      var gitHubProject = await GitHubProject.createForThisProject();
      // check if the project is on github.com
      gitHubProject.uri;
      variables[GitHubProject.id] = gitHubProject;
    } catch (e) {
      print('Error: Could not find this project on github.com');
      exit(65);
    }

    try {
      var pubDevProject = await PubDevProject.createForThisProject();
      // check if the project is on pub.dev
      pubDevProject.uri;
      variables[PubDevProject.id] = pubDevProject;
    } catch (e) {
      print('Warning: Could not find the project on pub.dev');
    }
    return variables;
  }

  Future<void> parseRenderAndWrite(
    SetupTemplate template,
    VariableMap variables,
  ) async {
    var parseResult = await engine.parseTemplate(template);
    var renderResult = await engine.render(parseResult, variables);
    if (renderResult.errorMessage.isNotEmpty) {
      print('  Error: ${renderResult.errorMessage}');
      return;
    }
    if (packageIsDocumentationBuilder()) {
      // we are not overriding any files in the documentation_builder package
      // so we just print the result to the console
      print(renderResult.text);
      return;
    }
    await template.output.create(recursive: true);
    await template.output.writeAsString(renderResult.text);
  }

  Future<void> copyFile(SetupTemplate template) async {
    final bytes = await readAsBytesFromHttps(template.input);
    await template.output.create(recursive: true);
    await template.output.writeAsBytes(bytes);
  }

  bool hasGitWorkflowFiles() {
    var gitWorkflowsDir = Directory('.github/workflows');
    if (!gitWorkflowsDir.existsSync()) {
      return false;
    }

    final hasFiles = gitWorkflowsDir
        .listSync(recursive: true)
        .whereType<File>()
        .isNotEmpty;
    return hasFiles;
  }

  Future readAsBytesFromHttps(Uri input) async {
    if (!input.isAbsolute || input.scheme != 'https') {
      throw ArgumentError('Input URI must be an absolute HTTPS URI.');
    }
    final response = await http.get(input);
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to download file: ${input.toString()} (status: ${response.statusCode})',
      );
    }
    return response.bodyBytes;
  }

  Future<void> addOrUpdateBuildYaml() async {
    if (packageIsDocumentationBuilder()) {
      print('$documentationBuilder build.yaml will not be overridden.');
      return;
    }
    final buildYamlFile = File('build.yaml');
    if (!await buildYamlFile.exists()) {
      print('creating build.yaml file ...');
      await buildYamlFile.create();
    } else {
      print('updating build.yaml file ...');
    }
    var yamlString = await buildYamlFile.readAsString();
    var yaml = parseYaml(
      yamlString: yamlString,
      sourcePath: buildYamlFile.path,
    );
    var mergedYaml = mergeDocumentationBuilderBuildYaml(yaml);
    await buildYamlFile.writeAsString(mergedYaml.toString());
  }
}

typedef CliTemplateFile = ({File input, File output});

bool hasDependency(YamlMagic yaml, String package) {
  if (yaml.map.containsKey('dependencies')) {
    final dependencies = yaml['dependencies'];
    if (dependencies is Map && dependencies.containsKey(package)) {
      return true;
    }
  }

  if (yaml.map.containsKey('dev_dependencies')) {
    final devDeps = yaml['dev_dependencies'];
    if (devDeps is Map && devDeps.containsKey(package)) {
      return true;
    }
  }

  return false;
}

/// Adds a package as a dev dependency using 'dart pub add'.
Future<void> addDevDependency(String package) async {
  try {
    final shell = Shell();
    await shell.run('dart pub add $package --dev');
  } catch (e) {
    //the error is already printed by the shell
    exit(65);
  }
}
