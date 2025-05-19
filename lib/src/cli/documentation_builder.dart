import 'dart:io';

import 'package:collection/collection.dart';
import 'package:process_run/shell.dart';

Future<void> main(List<String> args) async {
  var result = Commands().find(args);

  if (result is CommandLineFailure) {
    print(result.error);
    exit(255);
  }

  if (result is CommandLineSuccess) {
    await result.command.run();
    exit(0);
  }

  exit(0);
}

abstract class Command {
  String get name;
  String get description;

  Future<void> run();
}

class Commands extends UnmodifiableListView<Command> {
  Commands()
      : super([
          HelpCommand(),
          BuildCommand(),
        ]);

  String get availableCommandsText =>
      'Available commands:\n' +
      map((command) => ' ${command.name.padRight(6)}  ${command.description}')
          .join('\n');

  CommandLineResult? find(List<String> args) {
    if (args.isEmpty) {
      return CommandLineFailure('No command argument provided.');
    }
    if (args.length > 1) {
      return CommandLineFailure('Too many arguments.');
    }
    final commandName = args[0].toLowerCase();
    final command = Commands()
        .firstWhereOrNull((cmd) => cmd.name.toLowerCase() == commandName);
    if (command == null) {
      return CommandLineFailure('Command not found. ');
    }

    return CommandLineSuccess(command);
  }
}

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

class BuildCommand extends Command {
  @override
  final String name = 'build';

  @override
  final String description =
      'Builds the documentation files from template files by starting build_runner build.';

  @override
  Future<void> run() async {
    var shell = Shell();
    await shell.run("dart run build_runner build --delete-conflicting-outputs --verbose");
  }
}
