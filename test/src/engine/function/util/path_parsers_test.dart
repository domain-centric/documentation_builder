import 'package:test/test.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('ProjectFilePath', () {
    test('validates correct relative paths', () {
      Should.notThrowException((() => ProjectFilePath2('lib/my_library.dart')));
    });

    test('throws exception for invalid relative paths', () {
      Should.notThrowException(() => ProjectFilePath2('lib//my_library.dart'));
    });

    test('extracts file name correctly', () {
      var path = ProjectFilePath2('lib/my_library.dart');
      path.fileName.should.be('my_library.dart');
    });

    test('generates correct GitHub URI', () {
      var path = ProjectFilePath2('lib/my_library.dart');
      path.githubUri.toString().should.be(
        'https://github.com/domain-centric/template_engine/blob/main/lib/my_library.dart',
      );
    });

    test('generates correct GitHub markdown link', () {
      var path = ProjectFilePath2('lib/my_library.dart');
      path.githubMarkdownLink.should.be(
        '<a href="https://github.com/domain-centric/template_engine/blob/main/lib/my_library.dart">my_library.dart</a>',
      );
    });
  });

  group('DartMemberPath', () {
    test('parses valid member paths', () {
      Should.notThrowException(() => DartMemberPath('MyClass.myMethod'));
    });

    test('throws exception for invalid member paths', () {
      Should.throwException(() => DartMemberPath('MyClass..myMethod'));
    });
  });

  group('SourcePath', () {
    test('parses valid code paths', () {
      Should.notThrowException(
        () => SourcePath('lib/my_library.dart|MyClass.myMethod'),
      );
    });

    test('throws exception for invalid code paths', () {
      Should.throwException<Exception>(
        () => SourcePath('lib\\my_library.dart|MyClass.myMethod'),
      ).toString().should.be(
        "Exception: Invalid Dart code path: 'lib\\my_library.dart|MyClass.myMethod'"
        ': letter expected OR digit expected OR "(" expected OR ")" expected OR '
        '"_" expected OR "-" expected OR "." expected at position: 3',
      );
      Should.throwException<Exception>(
        () => SourcePath('lib/my_library.dart|MyClass..myMethod'),
      ).toString().should.be(
        "Exception: Invalid Dart code path: 'lib/my_library.dart|MyClass..myMethod':"
        ' letter expected OR digit expected OR "(" expected OR ")" expected OR "_"'
        ' expected OR "-" expected OR "." expected at position: 19',
      );
      Should.throwException<Exception>(
        () => SourcePath('lib/my_library.dart#MyClass..myMethod'),
      ).toString().should.be(
        "Exception: Invalid Dart code path: 'lib/my_library.dart#MyClass..myMethod'"
        ': letter expected OR digit expected OR "(" expected OR ")" expected OR "_"'
        ' expected OR "-" expected OR "." expected at position: 19',
      );
    });

    test('extracts file path correctly', () {
      var codePath = SourcePath('lib/my_library.dart#MyClass.myMethod');
      codePath.projectFilePath.toString().should.be('lib/my_library.dart');
    });

    test('extracts member path correctly', () {
      var codePath = SourcePath('lib/my_library.dart#MyClass.myMethod');
      codePath.dartLibraryMemberPath.toString().should.be('MyClass.myMethod');
    });
  });
}
