import 'package:test/test.dart';
import 'package:documentation_builder/src/engine/function/import.dart';
import 'package:shouldly/shouldly.dart';

import 'util/reference_test.dart';

void main() {
  group('ImportCode', () {
    test('should import code and wrap in markdown code block', () async {
      final importCode = importCodeFunction;
      final argumentValues = {
        ImportFunctionArgumentName.source:
            'test/src/engine/function/import_test.dart',
        ImportFunctionArgumentName.language: 'dart',
        ImportFunctionArgumentName.sourceHeader: true,
      };
      final result = await importCode.function(
        FakeFunctionCallContext(
          FakeRenderContext({}),
          argumentValues: argumentValues,
        ),
      );
      result.should.contain('```dart');
      result.should.contain('test/src/engine/function/import_test.dart');
      result.should.endWith('```\n');
    });

    test('should not include source header if sourceHeader is false', () async {
      final importCode = importCodeFunction;
      final argumentValues = {
        ImportFunctionArgumentName.source:
            'test/src/engine/function/generator_test.dart',
        ImportFunctionArgumentName.language: 'dart',
        ImportFunctionArgumentName.sourceHeader: false,
      };
      final result = await importCode.function(
        FakeFunctionCallContext(
          FakeRenderContext({}),
          argumentValues: argumentValues,
        ),
      );
      result.should.not.contain('test/src/engine/function/generator_test.dart');
    });

    test('should throw if file does not exist', () async {
      final importCode = importCodeFunction;
      final argumentValues = {
        ImportFunctionArgumentName.source: 'not_a_real_file.dart',
        ImportFunctionArgumentName.language: 'dart',
        ImportFunctionArgumentName.sourceHeader: true,
      };
      try {
        await importCode.function(
          FakeFunctionCallContext(
            FakeRenderContext({}),
            argumentValues: argumentValues,
          ),
        );
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
      final importDartCode = importDartCodeFunction;
      final argumentValues = {
        ImportFunctionArgumentName.source:
            'test/src/engine/function/import_test.dart',
        ImportFunctionArgumentName.sourceHeader: true,
      };
      final result = await importDartCode.function(
        FakeFunctionCallContext(
          FakeRenderContext({}),
          argumentValues: argumentValues,
        ),
      );
      result.should.contain('```dart');
    });
  });
}
