import 'dart:collection';
import 'dart:io';

import 'package:build/build.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:petitparser/petitparser.dart';

/// Alternative [ProjectFilePath2] other than [template_engine] package, because we need to do without endWithBetterFailure() for [SourcePath];
class ProjectFilePath2 {
  final String relativePath;



  static Parser<String> _fileOrFolderName() => (ChoiceParser([
        letter(),
        digit(),
        char('('),
        char(')'),
        char('_'),
        char('-'),
        char('.'),
      ], failureJoiner: selectFarthestJoined))
          .plus()
          .flatten();

  static Parser<String> _slashAndFileOrFolderName() =>
      (char('/') & _fileOrFolderName()).map((values) => values[1]);

  static Parser<List<String>> _pathParser() =>
      (_fileOrFolderName() & (_slashAndFileOrFolderName().star()))
          .map<List<String>>((values) => [values[0], ...values[1]]);
  //.endWithBetterFailure();

  ProjectFilePath2(String relativePath) :this.relativePath=normalize(relativePath) {
    validate(relativePath);
  }

  void validate(String path) {
    var result = _pathParser().parse(path);
    if (result is Failure) {
      throw Exception("Invalid project file path: '$path': ${result.message} "
          "at position: ${result.position + 1}");
    }
  }

  String get fileName {
    var value2 = _pathParser().parse(relativePath).value;
    return value2.last;
  }

  Uri get githubUri =>
      Uri.parse('https://github.com/domain-centric/template_engine/blob/main/'
          '$relativePath');

  String get githubMarkdownLink => '<a href="$githubUri">$fileName</a>';

  @override
  String toString() => relativePath;
  
  /// when [AssetId] is used as relative path, it could be missing the lib folder.
  /// if so the lib folder is added
  static String normalize(String relativePath) {
       var filePath = [
      ...LocalProject.directory.path.split(Platform.pathSeparator),
      ...relativePath.split('/'),
    ].join(Platform.pathSeparator);
    if (File(filePath).existsSync()) {
        return relativePath;
    }
    filePath = [
      ...LocalProject.directory.path.split(Platform.pathSeparator),
      'lib',
      ...relativePath.split('/'),
      ].join(Platform.pathSeparator);
     if (File(filePath).existsSync()) {
        return 'lib/$relativePath';
    } 
    return relativePath;
  }
}

extension EndOrPreviousFailureExtension<R> on Parser<R> {
  Parser<R> endOrPreviousFailure() =>
      skip(after: EndOfInputOrPreviousFailureParser(this));
}

/// A parser that succeeds at the end of input.
/// OR results with an failure with the message of the owning parser
/// Inspired by [EndOfInputParser]
class EndOfInputOrPreviousFailureParser extends Parser<void> {
  final Parser parser;
  EndOfInputOrPreviousFailureParser(this.parser);

  @override
  Result<void> parseOn(Context context) {
    if (context.position < context.buffer.length) {
      var contextUpToFault = parser.parseOn(context);
      var fault = parser.parseOn(contextUpToFault);
      return fault;
    }
    return context.success(null);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length ? -1 : position;

  @override
  String toString() => '${super.toString()}[$parser]';

  @override
  EndOfInputOrPreviousFailureParser copy() =>
      EndOfInputOrPreviousFailureParser(parser);

  @override
  bool hasEqualProperties(EndOfInputOrPreviousFailureParser other) =>
      super.hasEqualProperties(other) && parser == other.parser;
}

/// A [SourcePath] is a reference to a piece of your Dart source code.
/// This could be anything from a whole dart file to one of its members.
/// Format: <[ProjectFilePath2]>#<[DartMemberPath]>
/// - <[ProjectFilePath2]> (required) is a relative path to a Dart file, e.g. lib/my_library.dart
/// - #: the <[ProjectFilePath2]> and <[DartMemberPath]> are separated with a hash character
/// - <[DartMemberPath]> is a dot separated path to the member inside the Dart file, e.g.:
///   - constant name
///   - function name
///   - Enum name (optionally followed by a dot and a enum value)
///   - Class name (optionally followed by a dot and a class member such as a field name or method name)
///   - Extension name  (optionally followed by a dot and a extension member such as a field name or method name)
///
/// Examples:
/// - lib/my_library.dart
/// - lib/my_library.dart#myConstant
/// - lib/my_library.dart#myFunction
/// - lib/my_library.dart#MyEnum
/// - lib/my_library.dart#MyEnum.myValue
/// - lib/my_library.dart#MyClass
/// - lib/my_library.dart#MyClass.myFieldName
/// - lib/my_library.dart#MyClass.myFieldName.get
/// - lib/my_library.dart#MyClass.myFieldName.set
/// - lib/my_library.dart#MyClass.myMethod
/// - lib/my_library.dart#MyExtension
/// - lib/my_library.dart#MyExtension.myFieldName
/// - lib/my_library.dart#MyExtension.myFieldName.get
/// - lib/my_library.dart#MyExtension.myFieldName.set
/// - lib/my_library.dart#MyExtension.myMethod
class SourcePath {
  late ProjectFilePath2 projectFilePath;
  late DartMemberPath? dartLibraryMemberPath;

  static pathParser() => (ProjectFilePath2._pathParser()
              .map((values) => ProjectFilePath2(values.join('/'))) &
          (char('#') &
                  DartMemberPath._pathParser()
                      .map((values) => DartMemberPath(values.join('.'))))
              .repeat(0, 1))
      .endOrPreviousFailure();

  SourcePath(String path) {
    var result = pathParser().parse(path);
    if (result is Failure) {
      throw Exception("Invalid Dart code path: '$path': ${result.message} "
          "at position: ${result.position}");
    }
    var values = result.value;
    projectFilePath = values.first;
    dartLibraryMemberPath =
        values.last.isEmpty ? null : result.value.last.first.last;
  }

}

/// A [DartMemberPath] is a dot separated path to a member inside the Dart file.
/// It is a part of a [SourcePath].
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
class DartMemberPath extends UnmodifiableListView<String> {
  DartMemberPath._(super.identifiers);

  factory DartMemberPath(String path) {
    var result = _pathParser().parse(path);
    if (result is Failure) {
      throw Exception("Invalid Dart member path: '$path': ${result.message} "
          "at position: ${result.position + 1}");
    }
    return DartMemberPath._(result.value);
  }

  static Parser<String> _identifierName() =>
      (_firstCharacter() & _followingCharacters()).flatten();

  static Parser<String> _firstCharacter() =>
      (letter() | char('_')).repeat(1).flatten();

  static Parser<String> _followingCharacters() =>
      ((letter() | digit()).star().flatten());

  static Parser<String> _dotAndIdentifierName() =>
      (char('.') & _identifierName()).map((values) => values.last);

  static Parser<List<String>> _pathParser() =>
      (_identifierName() & (_dotAndIdentifierName().star()))
          .map<List<String>>((values) => [values[0], ...values[1]])
          .endOrPreviousFailure();

  DartMemberPath withoutParent() => DartMemberPath._(sublist(1));

  @override
  String toString() => join('.');

}

String normalizePathSeparators(String path, String pathSeparator) =>
      path.replaceAll('\\', pathSeparator).replaceAll('/', pathSeparator);
