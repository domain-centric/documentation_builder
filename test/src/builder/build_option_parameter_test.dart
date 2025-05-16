import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/build_option_parameter.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('InputPath', () {
    test('should return default value when not configured', () {
      final inputPath = InputPath();
      final builderOptions = BuilderOptions({});
      final value = inputPath.getValue(builderOptions);

      value.should.be('doc/template/{{filePath}}.template');
    });

    test('should return configured value when provided', () {
      final inputPath = InputPath();
      final builderOptions =
          BuilderOptions({'inputPath': 'custom/path/{{filePath}}.template'});
      final value = inputPath.getValue(builderOptions);

      value.should.be('custom/path/{{filePath}}.template');
    });

    test('should throw exception for invalid type', () {
      final inputPath = InputPath();
      final builderOptions = BuilderOptions({'inputPath': 123});

      Should.throwException<BuildOptionParameterException>(
          () => inputPath.getValue(builderOptions));
    });
  });

  group('OutputPath', () {
    test('should return default value when not configured', () {
      final outputPath = OutputPath();
      final builderOptions = BuilderOptions({});
      final value = outputPath.getValue(builderOptions);

      value.should.be('{{filePath}}');
    });

    test('should return configured value when provided', () {
      final outputPath = OutputPath();
      final builderOptions =
          BuilderOptions({'outputPath': 'custom/output/{{filePath}}'});
      final value = outputPath.getValue(builderOptions);

      value.should.be('custom/output/{{filePath}}');
    });

    test('should throw exception for invalid type', () {
      final outputPath = OutputPath();
      final builderOptions = BuilderOptions({'outputPath': 123});

      Should.throwException<BuildOptionParameterException>(
          () => outputPath.getValue(builderOptions));
    });
  });

  group('FileHeaders', () {
    test('should return default value when not configured', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({});
      final value = fileHeaders.getValue(builderOptions);
      value.should.be(fileHeaders.defaultValue);
    });

    test('should return configured value when provided', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({
        'fileHeaders': {
          '.txt': 'Generated from {{inputFile()}}',
        }
      });
      final value = fileHeaders.getValue(builderOptions);

      value.map.should.be({
        '.txt': 'Generated from {{inputFile()}}',
      });
    });

    test('should throw exception for invalid type', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({'fileHeaders': 'invalid'});

      Should.throwException<BuildOptionParameterException>(
          () => fileHeaders.getValue(builderOptions));
    });

    test('should find correct template for file extension', () async {
      final fileHeaders = FileHeaders();
      final assetId = AssetId('test_package', 'lib/test_file.md');
      final template = fileHeaders.defaultValue.findFor(assetId);
      template.should.not.beNull();
      final text = await template!.text;
      text.should.be(
          '[//]: # (This file was generated from: {{inputPath()}} using the documentation_builder package)$newLine');
    });

    test('should return null for unsupported file extension', () {
      final fileHeaders = FileHeaders();
      final assetId = AssetId('test_package', 'lib/test_file.unknown');
      final template = fileHeaders.defaultValue.findFor(assetId);
      template.should.beNull();
    });
  });
}
