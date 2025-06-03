import 'package:build/build.dart';
import 'package:documentation_builder/documentation_builder.dart';
import 'package:template_engine/template_engine.dart';
import 'package:collection/collection.dart';
import 'package:yaml_magic/yaml_magic.dart';

/// Configure the documentation_builder
/// Add a build.yaml file to the root of your project with the following lines (or merge lines if build.yaml file already exists):
///   ```
///   targets:
///     $default:
///       sources:
///       - doc/**
///       - lib/**
///       - bin/**
///       - web/**
///       - test/**
///       - pubspec.*
///       - $package$
///       builders:
///         documentation_builder|documentation_builder:
///           enabled: True
///           # options:
///             # input_path:
///               # An expression where to find template files
///               # Defaults to 'doc/template/{{filePath}}.template'
///             # output_path:
///               # An expression where to store the result files
///               # Defaults to '{{filePath}}'
///             # file_headers:
///               # A map of file output suffixes and the file header template to be added (which can be null), defaults to:
///            # LICENSE: null
///            # LICENSE.md: null
///            # .md: '[//]: "# (This file was generated from: {{inputPath()}} using the documentation_builder package)"
///            # .dart: "// This file was generated from: {{inputPath()}} using the documentation_builder package"
///   ```
///   For more information on the build.yaml file see [build_config](https://pub.dev/documentation/build_config/latest/)
YamlMagic mergeDocumentationBuilderBuildYaml(YamlMagic source) {
  // This function should merge the provided yaml with the default configuration.
  // Define the default configuration as a YamlMap.
  final toAdd = YamlMagic.fromString(
    content: '''
targets:
  \$default:
    sources:
      - doc/**
      - lib/**
      - bin/**
      - web/**
      - test/**
      - pubspec.*
      - \$package\$
    builders:
      documentation_builder|documentation_builder:
        enabled: True
        # options:
          # input_path:
            # An expression where to find template files
            # Defaults to 'doc/template/{{filePath}}.template'
          # output_path:
            # An expression where to store the result files
            # Defaults to '{{filePath}}'
          # file_headers:
            # A map of file output suffixes and the file header template to be added (which can be null), defaults to:
            # LICENSE: null
            # LICENSE.md: null
            # .md: '[//]: "# (This file was generated from: {{inputPath()}} using the documentation_builder package)"
            # .dart: "// This file was generated from: {{inputPath()}} using the documentation_builder package"
''',
    path: 'build.yaml',
  );

  return yamlDeepMerge(source, toAdd);
}

abstract class BuildOptionParameter<T> {
  final String name;

  /// A function that throws an explanatory exception
  /// when the value is not valid.
  final Function(T value)? validator;

  BuildOptionParameter({required this.name, this.validator});

  T getValue(BuilderOptions builderOptions) {
    var config = builderOptions.config;
    if (!config.containsKey(name)) {
      throw BuildOptionParameterException.isNotDefined(name);
    }
    var value = config[name];
    _validate(value);
    return value;
  }

  void _validate(dynamic value) {
    _validateValueType(value);
    if (validator != null) {
      try {
        validator!(value);
      } on Exception catch (e) {
        throw BuildOptionParameterException(name, 'has a validation error: $e');
      }
    }
  }

  void _validateValueType(dynamic value) {
    if (value is! T) {
      throw BuildOptionParameterException(name, 'is not of type: $T');
    }
  }
}

class BuildOptionParameterException implements Exception {
  final String parameterName;
  final String message;

  BuildOptionParameterException(this.parameterName, String message)
    : message = 'build.yaml: Builder option $parameterName $message';

  factory BuildOptionParameterException.isNotDefined(String parameterName) =>
      BuildOptionParameterException(parameterName, 'is not defined');

  @override
  toString() => message;
}

/// * Description: An expression where to find template files
/// * Default value: `'doc/template/{{filePath}}.template'`
class InputPath extends BuildOptionParameter<String> {
  InputPath() : super(name: 'input_path');
}

/// * Description: An expression where to store the result files
/// * Default value: `'{{filePath}}'`
class OutputPath extends BuildOptionParameter<String> {
  OutputPath() : super(name: 'output_path');
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
  FileHeaders() : super(name: 'file_headers');

  @override
  FileHeaderMap getValue(BuilderOptions builderOptions) {
    var config = builderOptions.config;
    if (!config.containsKey(name)) {
      throw BuildOptionParameterException.isNotDefined(name);
    }
    var map = config[name];
    if (map is! Map) {
      throw BuildOptionParameterException(name, 'is not of type: Map');
    }
    if (map.keys.any((key) => key is! String)) {
      throw BuildOptionParameterException(
        name,
        'contains keys that are not of type: String',
      );
    }
    if (map.values.any((value) => value is! String?)) {
      throw BuildOptionParameterException(
        name,
        'contains values that are not of type: String or null',
      );
    }
    var stringMap = map.map(
      (key, value) => MapEntry(key as String, value as String?),
    );
    return FileHeaderMap(stringMap);
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
