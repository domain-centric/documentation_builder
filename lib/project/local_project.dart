import 'dart:io';

/// Provides information on the local project such as:
/// - name
/// - relevant local [Directory]s and [File]s
class LocalProject {

  /// Assuming the build_runner is started in the appropriate project [Directory]
  static Directory get directory => Directory.current;

  static String get name => directory.path.split(Platform.pathSeparator).last;

}
