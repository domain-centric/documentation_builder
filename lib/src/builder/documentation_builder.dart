import 'dart:io';

import 'template_builder.dart';

/// Generates markdown documentation files from markdown template files.
/// This can be useful when you write documentation for a
/// [Dart](https://dart.dev/) or [Flutter](https://flutter.dev/) project
/// and want to reuse/import Dart code or Dart documentation comments.
///
/// It can generate the following files:
/// - [ReadMeFile]
/// - [ChangeLogFile]
/// - [ExampleFile]
/// - GitHub [WikiFile]s
///
/// [documentation_builder] is not intended to generate API documentation.
/// Use [dartdoc](https://dart.dev/tools/dartdoc) instead.

// [DocumentationBuilder] isn't actually a builder. Its purpose:
// - for documentation
// - a convenient way to run the shell commands to start the builder,
//   using the build_runner package
class DocumentationBuilder {
  /// The [documentation_builder] uses several builders that are run with the [build_runner] package.
  ///
  /// The [build_runner] is started with the following command in the root of the project (ALT+F12 if you are using [Android Studio](https://developer.android.com/studio) or [Intellij](https://www.jetbrains.com/idea/)):\
  /// ```dart run build_runner build --delete-conflicting-outputs```
  ///
  /// You’d better clean up before you re-execute [build_runner]:\
  /// ```dart run build_runner clean```
  run() async {
    // TODO create shell class, e.g.:
    // e.g. Shell.run('''
    // flutter packages pub run build_runner clean
    // flutter packages pub run build_runner build --delete-conflicting-outputs
    // ''', StopMode.onErrorOrWarning);
    //  or maybe there is an existing shell package?

    var result = await Process.run(
      'dart',
      ['run', 'build_runner', 'clean'],
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }
}
