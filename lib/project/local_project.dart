import 'dart:io';

import 'package:build/src/builder/build_step.dart';

/// Provides information on the local project such as:
/// - name
/// - relevant local [Directory]s and [File]s
class LocalProject {
  static LocalProject _singleton = LocalProject._();

  factory LocalProject() => _singleton;

  LocalProject._();

  final Directory directory = _directory;

  final String name = _name;

  /// Assuming the build_runner is started in the appropriate project [Directory]
  static Directory get _directory => Directory.current;

  static String get _name => _directory.path.split(Platform.pathSeparator).last;

  // File get readMeFile =>
  //     File("${_directory.path}${Platform.pathSeparator}README.md");
  //
  // get changeLogFile =>
  //     File("${_directory.path}${Platform.pathSeparator}CHANGELOG.md");
  //
  // get exampleFile => File(
  //     "${_directory.path}${Platform.pathSeparator}example${Platform.pathSeparator}example.md");
  //
  // File wikiFile(String wikiFileName) => File(
  //     "${_directory.path}${Platform.pathSeparator}doc${Platform.pathSeparator}wiki${Platform.pathSeparator}$wikiFileName");

//TODO exampleFile
//TODO wikiDirectory

}
