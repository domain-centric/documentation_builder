import 'dart:io';

import 'package:build/build.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:http/http.dart' as http;

import '../project/local_project.dart';
import 'documentation_model.dart';

/// A [ProjectFilePath] is a reference to a file in your source project
/// - The [ProjectFilePath] is always relative to root directory of the project directory.
/// - The [ProjectFilePath] will always be within the project directory, that is they will never contain "../".
/// - The [ProjectFilePath] always uses forward slashes as path separators, regardless of the host platform (also for Windows).
///
/// Example: doc/wiki/Home.md
class ProjectFilePath {
  final String path;

  static final _fileExtensionExpression = FluentRegex()
      .literal('.')
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_'),
          Quantity.oneOrMoreTimes());

  static final pathInProject = FluentRegex()
      .startOfLine()
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_'))
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_./'),
          Quantity.zeroOrMoreTimes())
      .group(_fileExtensionExpression, quantity: Quantity.zeroOrOneTime())
      .endOfLine();

  static final pathInParent = FluentRegex()
      .startOfLine()
      .literal('../')
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_'))
      .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-_./'),
          Quantity.zeroOrMoreTimes())
      .group(_fileExtensionExpression, quantity: Quantity.zeroOrOneTime())
      .endOfLine();

  ProjectFilePath(this.path, {bool isParentPath = false}) {
    if (isParentPath) {
      validateParentPath();
    } else {
      validateProjectPath();
    }
  }

  void validateProjectPath() {
    if (pathInProject.hasNoMatch(path)) {
      throw Exception('Invalid ProjectFilePath format: $path');
    }
  }

  void validateParentPath() {
    if (pathInParent.hasNoMatch(path)) {
      throw Exception('Invalid ProjectFilePath format: $path');
    }
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

/// [UriSuffixPath] is a path that can be appended to a http [Uri]
/// It may only use valid [Uri] characters
///
/// Example: documentation_builder/issues?q=is%3Aissue+is%3Aclosed
class UriSuffixPath {
  final String path;

  static final expression = FluentRegex()
      .startOfLine()
      .characterSet(
          CharacterSet()
              .addLetters()
              .addDigits()
              .addLiterals('-._~:?#[]@!\$&()*+,;%=/'),
          Quantity.zeroOrMoreTimes())
      .endOfLine();

  UriSuffixPath(this.path) {
    validate();
  }

  void validate() {
    if (expression.hasNoMatch(path)) {
      throw Exception('Invalid UriSuffixPath format: $path');
    }
  }

  @override
  String toString() => path;
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

  static final List<FluentRegex> _operatorExpressions = [
    FluentRegex().literal('+'),
    FluentRegex().literal('-'),
    FluentRegex().literal('*'),
    FluentRegex().literal('/'),
    FluentRegex().literal('%'),
    FluentRegex().literal('<<'),
    FluentRegex().literal('>>'),
    FluentRegex().literal('>>>'),
    FluentRegex().literal('&'),
    FluentRegex().literal('&&'),
    FluentRegex().literal('^'),
    FluentRegex().literal('|'),
    FluentRegex().literal('||'),
    FluentRegex().literal('>='),
    FluentRegex().literal('>'),
    FluentRegex().literal('<='),
    FluentRegex().literal('<'),
    FluentRegex().literal('as'),
    FluentRegex().literal('is'),
    FluentRegex().literal('is!'),
    FluentRegex().literal('=='),
    FluentRegex().literal('!='),
    FluentRegex().literal('??'),
    FluentRegex().literal('='),
    FluentRegex().literal('*='),
    FluentRegex().literal('/='),
    FluentRegex().literal('+='),
    FluentRegex().literal('-='),
    FluentRegex().literal('&='),
    FluentRegex().literal('^='),
    FluentRegex().literal('|='),
  ];

  static final FluentRegex expression = FluentRegex()
      .startOfLine()
      .literal('_', Quantity.zeroOrOneTime())
      .characterSet(
          CharacterSet().addLetters().addDigits(), Quantity.oneOrMoreTimes())
      .group(
          FluentRegex().literal('.').or([
            FluentRegex().literal('_'),
            FluentRegex().group(FluentRegex()
                .literal('_', Quantity.zeroOrMoreTimes())
                .characterSet(CharacterSet().addLetters().addDigits(),
                    Quantity.oneOrMoreTimes())),
            ..._operatorExpressions,
          ]),
          quantity: Quantity.zeroOrMoreTimes())
      .endOfLine()
      .ignoreCase();

  DartMemberPath(this.path) {
    validate(path);
  }

  void validate(String path) {
    if (expression.hasNoMatch(path)) {
      throw Exception('Invalid DartMemberPath format: $path');
    }
  }

  @override
  String toString() => path;
}

/// A [DartFilePath] is a [ProjectFilePath] to a dart file.
/// It must end with a '.dart' extension.
///
/// Example: lib/my_library.dart
class DartFilePath extends ProjectFilePath {
  static final expression =
      FluentRegex(ProjectFilePath.pathInProject.endOfLine(false).toString())
          .literal('.dart')
          .endOfLine()
          .ignoreCase();

  DartFilePath(String path) : super(path);

  @override
  void validateProjectPath() {
    if (expression.hasNoMatch(path)) {
      throw Exception('Invalid DartFilePath format: $path');
    }
  }

  @override
  String toString() => path;
}

/// A [DartCodePath] is a reference to a piece of your Dart source code.
/// This could be anything from a whole dart file to one of its members.
/// Format: <[DartFilePath]>|<[DartMemberPath]>
/// - <[DartFilePath]> (required) is a [DartFilePath] to a Dart file without dart extension, e.g. lib/my_library.dart
/// - |: the <[DartFilePath]> and <[DartMemberPath]> are separated with a vertical bar | when there is a [DartMemberPath].
/// - <[DartMemberPath]> (optional) is a dot separated path to the member inside the Dart file, e.g.
///   - .constantName
///   - .functionName
///   - .EnumName (optionally followed by a dot and a enum value)
///   - .ClassName (optionally followed by a dot and a class member such as a field name or method name)
///   - .ExtensionName  (optionally followed by a dot and a extension member such as a field name or method name)
///
/// Examples:
/// - lib/my_library.dart
/// - lib/my_library.dart|myConstant
/// - lib/my_library.dart|myFunction
/// - lib/my_library.dart|MyEnum
/// - lib/my_library.dart|MyEnum.myValue
/// - lib/my_library.dart|MyClass
/// - lib/my_library.dart|MyClass.myFieldName
/// - lib/my_library.dart|MyClass.myFieldName.get
/// - lib/my_library.dart|MyClass.myFieldName.set
/// - lib/my_library.dart|MyClass.myMethod
/// - lib/my_library.dart|MyExtension
/// - lib/my_library.dart|MyExtension.myFieldName
/// - lib/my_library.dart|MyExtension.myFieldName.get
/// - lib/my_library.dart|MyExtension.myFieldName.set
/// - lib/my_library.dart|MyExtension.myMethod
class DartCodePath {
  static final expression = FluentRegex()
      .startOfLine()
      .group(DartFilePath.expression.startOfLine(false).endOfLine(false),
          type: GroupType.captureNamed(GroupName.dartFilePath))
      .group(
          FluentRegex().literal('|').group(
              DartMemberPath.expression.startOfLine(false).endOfLine(false),
              type: GroupType.captureNamed(GroupName.dartMemberPath)),
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
        expression.findCapturedGroups(path)[GroupName.dartFilePath];
    if (dartFilePath == null) {
      throw Exception(
          'Invalid DartCodePath, could not find DartFilePath: $path');
    }
    return DartFilePath(dartFilePath);
  }

  static DartMemberPath? _createDartMemberPath(String path) {
    String? dartMemberPath =
        expression.findCapturedGroups(path)[GroupName.dartMemberPath];
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

extension UriExtension on Uri {
  Uri withPathSuffix(String pathSuffix) {
    if (pathSuffix.trim().startsWith('/')) {
      return this.replace(path: path + pathSuffix);
    } else {
      return this.replace(path: path + '/' + pathSuffix);
    }
  }

  Future<bool> canGetWithHttp() async {
    var response = await http.get(this);
    var success = response.statusCode >= 200 && response.statusCode < 300;
    return success;
  }
}
