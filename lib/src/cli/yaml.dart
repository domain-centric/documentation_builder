// Merge the provided yaml with the defaultConfig.
// Deep merge: user config takes precedence.
import 'package:yaml_magic/yaml_magic.dart';

Map<String, dynamic> deepMerge(
  Map<String, dynamic> base,
  Map<String, dynamic> update,
) {
  final result = {...base};
  update.forEach((key, value) {
    if (value is Map<String, dynamic> && base[key] is Map) {
      result[key] = deepMerge(base[key], value);
    } else {
      result[key] = value;
    }
  });
  return result;
}

YamlMagic yamlDeepMerge(YamlMagic source, YamlMagic toAdd) {
  var merged = deepMerge(source.map, toAdd.map);
  source.map = merged;
  return source;
}

YamlMagic parseYaml({required String yamlString, required String sourcePath}) =>
    YamlMagic.fromString(content: yamlString, path: sourcePath);
