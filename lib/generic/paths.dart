import 'dart:io';

import 'package:documentation_builder/project/local_project.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:build/build.dart';


// TODO test code

/// [ProjectFilePath] is a reference to a file in your source project
/// - The [ProjectFilePath] is always relative to root directory of the project directory.
/// - The [ProjectFilePath] will always be within the project directory, that is they will never contain "../".
/// - The [ProjectFilePath] always uses forward slashes as path separators, regardless of the host platform (also for Windows).
/// Example: doc/wiki/Home.md
class ProjectFilePath {
  final String path;

  static final expression = FluentRegex()
      .characterSet(
      CharacterSet()
          .addLetters()
          .addDigits()
          .addLiterals('-_'))
      .characterSet(
      CharacterSet()
          .addLetters()
          .addDigits()
          .addLiterals('-_/'),
      Quantity.zeroOrMoreTimes());


  ProjectFilePath(this.path) {
    validate();
  }

  void validate() {
    if (!expression.hasMatch(path))
      throw Exception('Invalid ProjectFilePath format: $path');
  }

  @override
  String toString() => path;

  AssetId toAssetId() => AssetId(LocalProject.name, path);

  File toFile() => File(absoluteFilePath);

  String get absoluteFilePath => LocalProject.directory.path +
      Platform.pathSeparator +
      (path.replaceAll('/', Platform.pathSeparator));


  String get relativeToLibDirectory => '../$path';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProjectFilePath && runtimeType == other.runtimeType &&
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
      .characterSet(
      CharacterSet()
          .addLetters()
          .addDigits()
      , Quantity.oneOrMoreTimes())
      .group(FluentRegex()
      .literal('.')
      .characterSet(
      CharacterSet()
          .addLetters()
          .addDigits()
      , Quantity.oneOrMoreTimes()
  ), quantity: Quantity.zeroOrMoreTimes());


  DartMemberPath(this.path) {
    validate(path);
  }

  void validate(String path) {
    if (!expression.hasMatch(path))
      throw Exception('Invalid DartMemberPath: $path');
  }

  @override
  String toString() => path;
}


/// A [DartFilePath] is a [ProjectFilePath] to a dart file.
/// It must end with a '.dart' extension.
class DartFilePath extends ProjectFilePath {

  static final expression = FluentRegex.fromExpression(
      ProjectFilePath.expression.toString()).literal(
      '.dart');

  DartFilePath(String path) : super(path) ;

  @override
  void validate() {
    if (!expression.hasMatch(path)) {
      throw Exception('Invalid DartFilePath format: $path');
    }
  }

  @override
  String toString() => path;
}


/// A [DartCodePath] is a reference to a piece of your Dart source code.
/// This could be anything from a whole dart file to one of its members.
/// Format: <dartFilePath><dartMemberPath>
/// - <dartFilePath> (required) is [ProjectFilePath] to a Dart file without dart extension, e.g. lib/my_dart_file.dart
/// - <dartMemberPath> (optional) is a dot separated path to the member inside the Dart file, e.g.
///   - .constantName
///   - .functionName
///   - .EnumName (optionally followed by a dot and a enum value)
///   - .ClassName (optionally followed by a dot and a class member such as a field name or method name)
///   - .ExtensionName  (optionally followed by a dot and a extension member such as a field name or method name)
///
/// Examples:
/// - lib/my_dart_file.dart
/// - lib/my_dart_file.dart.myConstant
/// - lib/my_dart_file.dart.myFunction
/// - lib/my_dart_file.dart.MyEnum
/// - lib/my_dart_file.dart.MyEnum.myValue
/// - lib/my_dart_file.dart.MyClass
/// - lib/my_dart_file.dart.MyClass.myFieldName
/// - lib/my_dart_file.dart.MyClass.myFieldName.get
/// - lib/my_dart_file.dart.MyClass.myFieldName.set
/// - lib/my_dart_file.dart.MyClass.myMethod
/// - lib/my_dart_file.dart.MyExtension
/// - lib/my_dart_file.dart.MyExtension.myFieldName
/// - lib/my_dart_file.dart.MyExtension.myFieldName.get
/// - lib/my_dart_file.dart.MyExtension.myFieldName.set
/// - lib/my_dart_file.dart.MyExtension.myMethod
class DartCodePath {


  static final dartCodePathExpression = FluentRegex()
      .group(DartFilePath.expression
      , type: GroupType.captureNamed('dartFilePath'))
      .group(FluentRegex().literal('.').group(
      DartMemberPath.expression, type: GroupType.captureNamed('dartMemberPath')),
      quantity: Quantity.zeroOrOneTime());


  final String path;
  final DartFilePath projectFilePath;
  final DartMemberPath dartMemberPath;

  DartCodePath(this.path)
      : projectFilePath=_createProjectFilePath(path),
        dartMemberPath=_createDartMemberPath(path);

//TODO validation


  static _createProjectFilePath(String path) {
    validate(path);
  }

  static _createDartMemberPath(String path) {}

  @override
  String toString() => path;

  static void validate(String path) {
    if (!dartCodePathExpression.hasMatch(path)) {
      throw Exception('Invalid DartCodePath format: $path');
    }
  }

}

// TODO use paths everywere
