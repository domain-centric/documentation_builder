import 'dart:io';

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

//TODO readMeFile
//TODO ChangeLogFile
//TODO exampleFile
//TODO wikiDirectory

}
