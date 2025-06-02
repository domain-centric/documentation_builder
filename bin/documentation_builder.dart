import 'dart:io';
import 'dart:math';
import 'package:documentation_builder/src/cli/command.dart';
import 'package:http/http.dart' as http;
import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';
import 'package:yaml/yaml.dart';

import 'package:collection/collection.dart';
import 'package:process_run/shell.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// The simplest way to use the [documentation_builder] package
/// is to use it as a command line tool.
///
/// To install it, run `dart pub global activate documentation_builder` from the command line.
///
/// After installation you can use the following commands:
/// * `documentation_builder help`
///   Shows available commands.
/// * `documentation_builder setup`
///   Sets up a project to use the documentation_builder:
///   * Adds build_runner as dev dependency if needed\n'
///   * Adds documentation_builder as dev dependency if needed\n'
///   * Adds or updates build.yaml'
///   * Adds template files if needed\n'
///   * Adds github publish-wiki workflow if needed';.
/// * `documentation_builder build`
///   Generates documentation files from template files
///   by starting `build_runner build`.
Future<void> main(List<String> args) async {
  var result = Commands().find(args);

  if (result is CommandLineFailure) {
    print(result.error);
    exit(65);
  }

  if (result is CommandLineSuccess) {
    await result.command.run();
    exit(0);
  }

  exit(0);
}
