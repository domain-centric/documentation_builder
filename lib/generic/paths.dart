import 'dart:io';

import 'package:build/build.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// [ProjectFilePath] is a reference to a file in your source project
/// - The [ProjectFilePath] is always relative to root directory of the project directory.
/// - The [ProjectFilePath] will always be within the project directory, that is they will never contain "../".
/// - The [ProjectFilePath] always uses forward slashes as path separators, regardless of the host platform (also for Windows).
/// Example: doc/wiki/Home.md
class ProjectFilePath {
  final String path;

  static final _fileExtensionExpression = FluentRegex()
      .literal('.')
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_'),
          Quantity.oneOrMoreTimes());

  static final expression = FluentRegex()
      .startOfLine()
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_'))
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_/'),
          Quantity.zeroOrMoreTimes())
      .group(_fileExtensionExpression, quantity: Quantity.zeroOrOneTime())
      .endOfLine();

  ProjectFilePath(this.path) {
    validate();
  }

  void validate() {
    if (expression.hasNoMatch(path))
      throw Exception('Invalid ProjectFilePath format: $path');
  }

  @override
  String toString() => path;

  AssetId toAssetId() => AssetId(LocalProject.name, path);

  File toFile() => File(absoluteFilePath);

  String get absoluteFilePath =>
      LocalProject.directory.path +
      Platform.pathSeparator +
      (path.replaceAll('/', Platform.pathSeparator));

  String get relativeToLibDirectory => '../$path';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFilePath &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

/// A [DartMemberPath] is a dot separated path to a member inside the Dart file.
/// It is a part of a [DartCodePath].
///
/// Examples:
/// - myConstant
/// - myFunction
/// - MyEnum
/// - MyEnum.myValue
/// - MyClass
/// - MyClass.myFieldName
/// - MyClass.myFieldName.get
/// - MyClass.myFieldName.set
/// - MyClass.myMethod
/// - MyExtension
/// - MyExtension.myFieldName
/// - MyExtension.myFieldName.get
/// - MyExtension.myFieldName.set
/// - MyExtension.myMethod

class DartMemberPath {
  final String path;

  static final expression = FluentRegex()
      .startOfLine()
      .characterSet(
          CharacterSet().addLetters().addDigits(), Quantity.oneOrMoreTimes())
      .group(
          FluentRegex().literal('.').characterSet(
              CharacterSet().addLetters().addDigits(),
              Quantity.oneOrMoreTimes()),
          quantity: Quantity.zeroOrMoreTimes())
      .endOfLine();

  DartMemberPath(this.path) {
    validate(path);
  }

  void validate(String path) {
    if (expression.hasNoMatch(path))
      throw Exception('Invalid DartMemberPath format: $path');
  }

  @override
  String toString() => path;
}

/// A [DartFilePath] is a [ProjectFilePath] to a dart file.
/// It must end with a '.dart' extension.
class DartFilePath extends ProjectFilePath {
  static final expression =
      FluentRegex(ProjectFilePath.expression.endOfLine(false).toString())
          .literal('.dart')
          .endOfLine()
          .ignoreCase();

  DartFilePath(String path) : super(path);

  @override
  void validate() {
    if (expression.hasNoMatch(path)) {
      throw Exception('Invalid DartFilePath format: $path');
    }
  }

  @override
  String toString() => path;
}

/// A [DartCodePath] is a reference to a piece of your Dart source code.
/// This could be anything from a whole dart file to one of its members.
/// Format: <dartFilePath>|<dartMemberPath>
/// - <dartFilePath> (required) is [ProjectFilePath] to a Dart file without dart extension, e.g. lib/my_dart_file.dart
/// - |: the <dartFilePath> and <dartMemberPath> are separated with a vertical bar | when there is a <dartMemberPath>.
/// - <dartMemberPath> (optional) is a dot separated path to the member inside the Dart file, e.g.
///   - .constantName
///   - .functionName
///   - .EnumName (optionally followed by a dot and a enum value)
///   - .ClassName (optionally followed by a dot and a class member such as a field name or method name)
///   - .ExtensionName  (optionally followed by a dot and a extension member such as a field name or method name)
///
///
/// Examples:
/// - lib/my_dart_file.dart
/// - lib/my_dart_file.dart|myConstant
/// - lib/my_dart_file.dart|myFunction
/// - lib/my_dart_file.dart|MyEnum
/// - lib/my_dart_file.dart|MyEnum.myValue
/// - lib/my_dart_file.dart|MyClass
/// - lib/my_dart_file.dart|MyClass.myFieldName
/// - lib/my_dart_file.dart|MyClass.myFieldName.get
/// - lib/my_dart_file.dart|MyClass.myFieldName.set
/// - lib/my_dart_file.dart|MyClass.myMethod
/// - lib/my_dart_file.dart|MyExtension
/// - lib/my_dart_file.dart|MyExtension.myFieldName
/// - lib/my_dart_file.dart|MyExtension.myFieldName.get
/// - lib/my_dart_file.dart|MyExtension.myFieldName.set
/// - lib/my_dart_file.dart|MyExtension.myMethod
class DartCodePath {
  static final dartFilePathGroupName = 'dartFilePath';
  static final dartMemberPathGroupName = 'dartMemberPath';

  static final expression = FluentRegex()
      .startOfLine()
      .group(DartFilePath.expression.startOfLine(false).endOfLine(false),
          type: GroupType.captureNamed(dartFilePathGroupName))
      .group(
          FluentRegex().literal('|').group(
              DartMemberPath.expression.startOfLine(false).endOfLine(false),
              type: GroupType.captureNamed(dartMemberPathGroupName)),
          quantity: Quantity.zeroOrOneTime())
      .endOfLine()
      .ignoreCase();

  final String path;
  final DartFilePath dartFilePath;
  final DartMemberPath? dartMemberPath;

  DartCodePath(this.path)
      : dartFilePath = _createProjectFilePath(path),
        dartMemberPath = _createDartMemberPath(path);

  static DartFilePath _createProjectFilePath(String path) {
    validate(path);
    String? dartFilePath =
        expression.findCapturedGroups(path)[dartFilePathGroupName];
    if (dartFilePath == null)
      throw Exception(
          'Invalid DartCodePath, could not find DartFilePath: $path');
    return DartFilePath(dartFilePath);
  }

  static DartMemberPath? _createDartMemberPath(String path) {
    String? dartMemberPath =
        expression.findCapturedGroups(path)[dartMemberPathGroupName];
    if (dartMemberPath == null) {
      return null;
    } else {
      return DartMemberPath(dartMemberPath);
    }
  }

  static void validate(String path) {
    if (expression.hasNoMatch(path)) {
      throw Exception('Invalid DartCodePath format: $path');
    }
  }

  @override
  String toString() => path;
}
