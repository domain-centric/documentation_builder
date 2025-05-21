import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:template_engine/template_engine.dart';
import 'package:collection/collection.dart';

/// [documentation_builder] build options have default values.
/// You can override these default values by adding the following lines to the defaults section of a build.yaml file (merge these lines if build.yaml file already exists):
/// ```
/// targets:
///   $default:
///     builders:
///       documentation_builder:
///         options:
///           inputPath: #your input expression, see the default value for inspiration
///           outputPath: #your output expression, see the default value for inspiration
///           fileHeaders: #your fileHeaders expression, see the default value for inspiration
/// ```
/// For more information on the build.yaml file see [build_config](https://pub.dev/documentation/build_config/latest/)
abstract class BuildOptionParameter<T> {
  final String name;
  final T defaultValue;
  final String description;

  /// A function that throws an explanatory exception
  /// when the value is not valid.
  final Function(T value)? validator;

  BuildOptionParameter({
    required this.name,
    required this.description,
    required this.defaultValue,
    this.validator,
  });

  T getValue(BuilderOptions builderOptions) {
    var config = builderOptions.config;
    if (!config.containsKey(name)) {
      return defaultValue;
    }
    var value = config[name];
    _validate(value);
    return value;
  }

  void _validate(value) {
    _validateValueType(value);
    if (validator != null) {
      try {
        validator!(value);
      } on Exception catch (e) {
        throw BuildOptionParameterException(name, 'has a validation error: $e');
      }
    }
  }

  void _validateValueType(value) {
    if (value is! T) {
      throw BuildOptionParameterException(name, 'is not of type: $T');
    }
  }
}

class BuildOptionParameterException implements Exception {
  final String parameterName;
  final String message;

  BuildOptionParameterException(this.parameterName, String message)
    : message =
          'build.yaml: Builder option parameter ${parameterName} $message';
}

/// * Description: An expression where to find template files
/// * Default value: `'doc/template/{{filePath}}.template'`
class InputPath extends BuildOptionParameter<String> {
  InputPath()
    : super(
        name: 'inputPath',
        description: 'An expression where to find template files',
        defaultValue: 'doc/template/{{filePath}}.template',
      );
}

/// * Description: An expression where to store the result files
/// * Default value: `'{{filePath}}'`
class OutputPath extends BuildOptionParameter<String> {
  OutputPath()
    : super(
        name: 'outputPath',
        description: 'An expression where to store the result files',
        defaultValue: '{{filePath}}',
      );
}

/// * Description: A map of file suffixes and the file header template to be added (which can be null)
/// * Default value:
///   ```
///   {
///   'LICENSE': null,
///   'LICENSE.md': null,
///   '.md':
///       '[//]: # (This file was generated from: {{inputPath()}} using the documentation_builder package)&#92;n&#92;r',
///   '.dart':
///       '/// This file was generated from: {{inputPath()}} using the documentation_builder package&#92;n&#92;r'
///   }
///   ```
class FileHeaders extends BuildOptionParameter<FileHeaderMap> {
  FileHeaders()
    : super(
        name: 'fileHeaders',
        description:
            'A map of file suffices and the file header template to be added (which can be null)',
        defaultValue: FileHeaderMap({
          'LICENSE': null,
          'LICENSE.md': null,
          '.md':
              '[//]: # (This file was generated from: {{inputPath()}} using the documentation_builder package)$newLine',
          '.dart':
              '/// This file was generated from: {{inputPath()}} using the documentation_builder package$newLine',
        }),
      );

  @override
  FileHeaderMap getValue(BuilderOptions builderOptions) {
    var config = builderOptions.config;
    if (!config.containsKey(name)) {
      return defaultValue;
    }
    var map = config[name];
    if (map is! Map<String, String>) {
      throw BuildOptionParameterException(
        name,
        'is not of type: Map<String, String>',
      );
    }
    return FileHeaderMap(map);
  }
}

class FileHeaderMap {
  /// key = file suffix e.g.: '.md'
  /// value = header template
  final Map<String, String?> map;

  late List<String> fileSuffixes = map.keys.toList();

  FileHeaderMap(this.map);

  TextTemplate? findFor(AssetId outputId) {
    var outputFilePath = outputId.path;
    String? found = fileSuffixes.firstWhereOrNull(
      (suffix) => outputFilePath.endsWith(suffix),
    );
    if (found == null) {
      return null;
    }
    String? templateText = map[found];
    if (templateText == null) {
      return null;
    }
    return TextTemplate(templateText);
  }
}
