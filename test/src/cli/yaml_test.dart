import 'package:documentation_builder/documentation_builder.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';
import 'package:yaml_magic/yaml_magic.dart';

void main() {
  group('deepMerge', () {
    test('merges two flat maps', () {
      final base = {'a': 1, 'b': 2};
      final update = {'b': 3, 'c': 4};
      final result = deepMerge(base, update);
      result.should.be({'a': 1, 'b': 3, 'c': 4});
    });

    test('merges nested maps', () {
      final base = {
        'a': {'x': 1, 'y': 2},
        'b': 2,
      };
      final update = {
        'a': {'y': 3, 'z': 4},
        'c': 5,
      };
      final result = deepMerge(base, update);
      result.should.be({
        'a': {'x': 1, 'y': 3, 'z': 4},
        'b': 2,
        'c': 5,
      });
    });

    test('update overwrites non-map values', () {
      final base = {
        'a': 1,
        'b': {'x': 2},
      };
      final update = {
        'a': {'y': 3},
        'b': 3,
      };
      final result = deepMerge(base, update);
      result.should.be({
        'a': {'y': 3},
        'b': 3,
      });
    });
  });

  group('yamlDeepMerge', () {
    test('merges two YamlMagic objects', () {
      final source = YamlMagic.fromString(
        content: '''
    a: 1
    b:
      x: 2
    ''',
        path: '',
      );
      final toAdd = YamlMagic.fromString(
        content: '''
        b:
          y: 3
        c: 4
      ''',
        path: '',
      );
      final result = yamlDeepMerge(
        source,
        toAdd,
      ).toString().replaceAll('\n\n', '\n');
      result.should.be('''
a: 1
b:
  x: 2
  y: 3
c: 4
''');
    });

    test('handles empty toAdd', () {
      final source = YamlMagic.fromString(content: 'a: 1', path: '');
      final toAdd = YamlMagic.fromString(content: '', path: '');
      final result = yamlDeepMerge(source, toAdd);
      result.map.should.be({'a': 1});
    });

    test('handles empty source', () {
      final source = YamlMagic.fromString(content: '', path: '');
      final toAdd = YamlMagic.fromString(content: 'a: 2', path: '');
      final result = yamlDeepMerge(source, toAdd);
      result.map.should.be({'a': 2});
    });
  });

  group('parseYaml', () {
    test('parses valid YAML string', () {
      final yamlString = '''
          a: 1
          b:
            c: 2
        ''';
      final result = parseYaml(
        yamlString: yamlString,
        sourcePath: 'test.yaml',
      ).toString().replaceAll('\n\n', '\n');
      result.should.be('''
a: 1
b:
  c: 2
''');
    });

    test('throws on invalid YAML', () {
      final yamlString = 'a: [1, 2';
      Should.throwException(
        () => parseYaml(yamlString: yamlString, sourcePath: 'bad.yaml'),
      );
    });
  });
}
