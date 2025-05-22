import 'package:test/test.dart';
import 'package:documentation_builder/src/engine/function/import.dart';
import 'package:template_engine/template_engine.dart';
import 'package:shouldly/shouldly.dart';

import 'util/reference_test.dart';

void main() {
  group('ImportCode', () {
    test('should import code and wrap in markdown code block', () async {
      final importCode = ImportCode();
      final params = {
        ImportCode.sourceName: 'test/src/engine/function/import_test.dart',
        ImportCode.languageName: 'dart',
        ImportCode.sourceHeaderName: true,
      };
      final result = await importCode.function(
        '',
        FakeRenderContext(VariableMap()),
        params,
      );
      result.should.beOfType<String>();
      result as String;
      result.should.contain('```dart');
      result.should.contain('test/src/engine/function/import_test.dart');
      result.should.endWith('```\n');
    });

    test('should not include source header if sourceHeader is false', () async {
      final importCode = ImportCode();
      final params = {
        ImportCode.sourceName: 'test/src/engine/function/generator_test.dart',
        ImportCode.languageName: 'dart',
        ImportCode.sourceHeaderName: false,
      };
      final result = await importCode.function(
        '',
        FakeRenderContext(VariableMap()),
        params,
      );
      result.should.beOfType<String>();
      result as String;
      result.should.not.contain('test/src/engine/function/generator_test.dart');
    });

    test('should throw if file does not exist', () async {
      final importCode = ImportCode();
      final params = {
        ImportCode.sourceName: 'not_a_real_file.dart',
        ImportCode.languageName: 'dart',
        ImportCode.sourceHeaderName: true,
      };
      try {
        await importCode.function('', FakeRenderContext(VariableMap()), params);
        ShouldlyTestFailureError('should throw an error');
      } catch (e) {
        e.toString().should.startWith(
          "Exception: Error importing a pure file: Error reading: not_a_real_file.dart",
        );
      }
    });
  });

  group('ImportDartCode', () {
    test('should import dart code and set language to dart', () async {
      final importDartCode = ImportDartCode();
      final params = {
        ImportDartCode.sourceName: 'test/src/engine/function/import_test.dart',
        ImportDartCode.sourceHeaderName: true,
      };
      final result = await importDartCode.function(
        '',
        FakeRenderContext(VariableMap()),
        params,
      );
      result.should.beOfType<String>();
      result as String;
      result.should.contain('```dart');
    });
  });
}
