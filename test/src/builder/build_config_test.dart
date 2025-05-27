import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/build_config.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('InputPath', () {
    test('should throw an exception not configured', () {
      final inputPath = InputPath();
      final builderOptions = BuilderOptions({});
      Should.throwException<BuildOptionParameterException>(
        () => inputPath.getValue(builderOptions),
      )?.message.should.be(
        'build.yaml: Builder option input_path is not defined',
      );
    });

    test('should return configured value when provided', () {
      final inputPath = InputPath();
      final builderOptions = BuilderOptions({
        'input_path': 'custom/path/{{filePath}}.template',
      });
      final value = inputPath.getValue(builderOptions);

      value.should.be('custom/path/{{filePath}}.template');
    });

    test('should throw exception for invalid type', () {
      final inputPath = InputPath();
      final builderOptions = BuilderOptions({'input_path': 123});

      Should.throwException<BuildOptionParameterException>(
        () => inputPath.getValue(builderOptions),
      );
    });
  });

  group('OutputPath', () {
    test('should throw an exception when not configured', () {
      final outputPath = OutputPath();
      final builderOptions = BuilderOptions({});
      Should.throwException<BuildOptionParameterException>(
        () => outputPath.getValue(builderOptions),
      )?.message.should.be(
        'build.yaml: Builder option output_path is not defined',
      );
    });

    test('should return configured value when provided', () {
      final outputPath = OutputPath();
      final builderOptions = BuilderOptions({
        'output_path': 'custom/output/{{filePath}}',
      });
      final value = outputPath.getValue(builderOptions);

      value.should.be('custom/output/{{filePath}}');
    });

    test('should throw exception for invalid type', () {
      final outputPath = OutputPath();
      final builderOptions = BuilderOptions({'output_path': 123});

      Should.throwException<BuildOptionParameterException>(
        () => outputPath.getValue(builderOptions),
      );
    });
  });

  group('FileHeaders', () {
    test('should throw an exception when not configured', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({});
      Should.throwException<BuildOptionParameterException>(
        () => fileHeaders.getValue(builderOptions),
      )?.message.should.be(
        'build.yaml: Builder option file_headers is not defined',
      );
    });

    test('should throw an exception when not a map', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({'file_headers': 'string'});
      Should.throwException<BuildOptionParameterException>(
        () => fileHeaders.getValue(builderOptions),
      )?.message.should.be(
        'build.yaml: Builder option file_headers is not of type: Map',
      );
    });

    test(
      'should throw an exception when map contains a key that is not a String',
      () {
        final fileHeaders = FileHeaders();
        final builderOptions = BuilderOptions({
          'file_headers': {'key': 'value', 1234: 'value'},
        });
        Should.throwException<BuildOptionParameterException>(
          () => fileHeaders.getValue(builderOptions),
        )?.message.should.be(
          'build.yaml: Builder option file_headers contains keys that are not of type: String',
        );
      },
    );

    test(
      'should throw an exception when map contains a value that is not a String or null',
      () {
        final fileHeaders = FileHeaders();
        final builderOptions = BuilderOptions({
          'file_headers': {'key1': 'string', 'key2': null, 'key3': 123},
        });
        Should.throwException<BuildOptionParameterException>(
          () => fileHeaders.getValue(builderOptions),
        )?.message.should.be(
          'build.yaml: Builder option file_headers contains values that are not of type: String or null',
        );
      },
    );

    test('should return configured value when provided', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({
        'file_headers': {'.txt': 'Generated from {{inputFile()}}'},
      });
      final value = fileHeaders.getValue(builderOptions);

      value.map.should.be({'.txt': 'Generated from {{inputFile()}}'});
    });

    test('should throw exception for invalid type', () {
      final fileHeaders = FileHeaders();
      final builderOptions = BuilderOptions({'file_headers': 'invalid'});

      Should.throwException<BuildOptionParameterException>(
        () => fileHeaders.getValue(builderOptions),
      );
    });
  });
  group('FileHeaderMap', () {
    test('should find correct template for file extension', () async {
      final fileHeaderMap = FileHeaderMap({'.md': 'template'});
      final assetId = AssetId('test_package', 'lib/test_file.md');
      final template = fileHeaderMap.findFor(assetId);
      template.should.not.beNull();
      final text = await template!.text;
      text.should.be('template');
    });

    test('should return null for unsupported file extension', () {
      final fileHeaderMap = FileHeaderMap({'.md': 'template'});
      final assetId = AssetId('test_package', 'lib/test_file.unknown');
      final template = fileHeaderMap.findFor(assetId);
      template.should.beNull();
    });
  });
}
