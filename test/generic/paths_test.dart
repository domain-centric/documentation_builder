import 'package:documentation_builder/generic/paths.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:test/test.dart';

const String dartFilePath = 'lib/builder/documentation_builder.dart';

main() {
  group('class: ProjectFilePath', () {
    group('constructor', () {
      test("path should not begin with slash", () {
        String path = '/hello';
        expect(() {
          ProjectFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid ProjectFilePath format: $path'),
            )));
      });

      test("path should not begin with backslash", () {
        String path = '\\hello';
        expect(() {
          ProjectFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid ProjectFilePath format: $path'),
            )));
      });

      test("path should not contain a backslash", () {
        String path = 'hello\\all';
        expect(() {
          ProjectFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid ProjectFilePath format: $path'),
            )));
      });
      test("path may contain a slash", () {
        String path = 'hello/all';
        expect(ProjectFilePath(path).toString(), path);
      });

      test("path may contain a dash", () {
        String path = 'hello-all';
        expect(ProjectFilePath(path).toString(), path);
      });
      test("path may contain a underscore", () {
        String path = 'hello_all';
        expect(ProjectFilePath(path).toString(), path);
      });
      test("path may have a file extension", () {
        String path = 'lib\my_dart_file.dart';
        expect(ProjectFilePath(path).toString(), path);
      });
    });
    group('method: toAssetId', () {
      test("must return a valid AssetId", () {
        String path = 'doc/template/README.mdt';
        expect(ProjectFilePath(path).toAssetId().package, LocalProject.name);
        expect(ProjectFilePath(path).toAssetId().path, path);
      });
    });
    group('method toFile', () {
      test("must return an existing File", () {
        String path = 'doc/template/README.mdt';
        expect(ProjectFilePath(path).toFile().existsSync(), true);
      });
    });
  });

  group('class: DartMemberPath', () {
    group('constructor', () {
      test("path should not begin with slash", () {
        String path = '/hello';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not contain a slash", () {
        String path = 'hello/all';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not begin with backslash", () {
        String path = '\\hello';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not contain a dash", () {
        String path = 'hello-all';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not contain a underscore", () {
        String path = 'hello_all';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not contain a symbol", () {
        String path = 'hello%all';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path should not contain a backslash", () {
        String path = 'hello\\all';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });

      test("path start with a period", () {
        String path = '.hello';
        expect(() {
          DartMemberPath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartMemberPath format: $path'),
            )));
      });
      test("path may contain a period", () {
        String path = 'hello.all';
        expect(DartMemberPath(path).toString(), path);
      });
      test("path may contain upper and lower case and numbers", () {
        String path = 'HelloAll2';
        expect(DartMemberPath(path).toString(), path);
      });
    });
  });

  group('class: DartFilePath', () {
    group('constructor', () {
      test("path must end with dart extension", () {
        String path = 'hello';
        expect(() {
          DartFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartFilePath format: $path'),
            )));

        path = 'hello.dart';
        expect(DartFilePath(path).toString(), path);
        path = 'hello.DART';
        expect(DartFilePath(path).toString(), path);
      });
      test("path should not begin with slash", () {
        String path = '/hello.dart';
        expect(() {
          DartFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartFilePath format: $path'),
            )));
      });

      test("path should not begin with backslash", () {
        String path = '\\hello.dart';
        expect(() {
          DartFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartFilePath format: $path'),
            )));
      });

      test("path should not contain a backslash", () {
        String path = 'hello\\all.dart';
        expect(() {
          DartFilePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartFilePath format: $path'),
            )));
      });
      test("path may contain a slash", () {
        String path = 'hello/all.dart';
        expect(DartFilePath(path).toString(), path);
      });

      test("path may contain a dash", () {
        String path = 'hello-all.dart';
        expect(DartFilePath(path).toString(), path);
      });
      test("path may contain a underscore", () {
        String path = 'hello_all.dart';
        expect(DartFilePath(path).toString(), path);
      });
    });
    group('method: toAssetId', () {
      test("must return a valid AssetId", () {
        String path = 'lib/parser/documentation_builder.dart';
        expect(DartFilePath(path).toAssetId().package, LocalProject.name);
        expect(DartFilePath(path).toAssetId().path, path);
      });
    });
    group('method toFile', () {
      test("must return an existing File", () {
        String path = 'lib/builder/documentation_builder.dart';
        expect(DartFilePath(path).toFile().existsSync(), true);
      });
    });
  });

  group('class: DartCodePath', () {
    group('constructor: with DartFilePath only', () {
      test("path must end with dart extension", () {
        String path = 'hello';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));

        path = 'hello.dart';
        expect(DartCodePath(path).toString(), path);
        path = 'hello.DART';
        expect(DartCodePath(path).toString(), path);
      });
      test("path should not begin with slash", () {
        String path = '/hello.dart';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });

      test("path should not begin with backslash", () {
        String path = '\\hello.dart';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });

      test("path should not contain a backslash", () {
        String path = 'hello\\all.dart';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("path may contain a slash", () {
        String path = 'hello/all.dart';
        expect(DartCodePath(path).toString(), path);
      });

      test("path may contain a dash", () {
        String path = 'hello-all.dart';
        expect(DartCodePath(path).toString(), path);
      });
      test("path may contain a underscore", () {
        String path = 'hello_all.dart';
        expect(DartCodePath(path).toString(), path);
      });
    });
    group('constructor: with DartFilePath with DartMemberPath', () {
      test("dartMemberPath should not begin with slash", () {
        String path = '$dartFilePath|/hello';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not contain a slash", () {
        String path = '$dartFilePath|hello/all';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not begin with backslash", () {
        String path = '$dartFilePath|\\hello';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not contain a dash", () {
        String path = '$dartFilePath|hello-all';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not contain a underscore", () {
        String path = '$dartFilePath|hello_all';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not contain a symbol", () {
        String path = '$dartFilePath|hello%all';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath should not contain a backslash", () {
        String path = '$dartFilePath|hello\\all';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });

      test("dartMemberPath start with a period", () {
        String path = '$dartFilePath|.hello';
        expect(() {
          DartCodePath(path);
        },
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid DartCodePath format: $path'),
            )));
      });
      test("dartMemberPath may contain a period", () {
        String path = '$dartFilePath|hello.all';
        expect(DartCodePath(path).toString(), path);
      });
      test("dartMemberPath may contain upper and lower case and numbers", () {
        String path = '$dartFilePath|HelloAll2';
        expect(DartCodePath(path).toString(), path);
      });
    });
    group('field: dartFilePath', () {
      test("returns correct path when only file is specified", () {
        String path = 'lib/builder/documentation_builder.dart';
        expect(DartCodePath(path).dartFilePath.toString(), path);
      });
      test("returns correct path when file and member is specified", () {
        String dartMemberPath = 'DocumentationBuilder.run';
        String dartCodePath = '$dartFilePath|$dartMemberPath';
        expect(
            DartCodePath(dartCodePath).dartFilePath.toString(), dartFilePath);
      });
      test("returns an existing path", () {
        expect(DartCodePath(dartFilePath).dartFilePath.toFile().existsSync(),
            true);
      });
    });
    group('field: dartMemberPath', () {
      test("returns null when only file is specified", () {
        String path = 'lib/parser/documentation_builder.dart';
        expect(DartCodePath(path).dartMemberPath, null);
      });
      test("returns correct path when file and member is specified", () {
        String dartMemberPath = 'DocumentationBuilder.run';
        String dartCodePath = '$dartFilePath|$dartMemberPath';
        expect(DartCodePath(dartCodePath).dartMemberPath.toString(),
            dartMemberPath);
      });
    });
  });
  group('class: UriSuffixPath', () {
    group('constructor', () {
      test("path may begin with slash", () {
        String path = '/hello';
        expect(UriSuffixPath.expression.hasMatch(path),true);
      });

      test("path should not begin with backslash", () {
        String path = '\\hello';
        expect(() {
          UriSuffixPath(path);
        },
            throwsA(isA<Exception>().having(
                  (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid UriSuffixPath format: $path'),
            )));
      });

      test("path should not contain a backslash", () {
        String path = 'hello\\all';
        expect(() {
          UriSuffixPath(path);
        },
            throwsA(isA<Exception>().having(
                  (e) => e.toString(),
              'toString()',
              equals('Exception: Invalid UriSuffixPath format: $path'),
            )));
      });
      test("path may contain '-._~:?#[]@!\$&()*+,;%=/'", () {
        String path = '-._~:?#[]@!\$&()*+,;%=/';
        expect(UriSuffixPath(path).toString(), path);
      });
    });
  });
}
