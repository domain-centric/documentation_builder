import 'dart:io';

import 'package:documentation_builder/src/project/local_project.dart';
import 'package:test/test.dart';

main() {
  group('class: LocalProject', () {
    test('field: directory', () {
      expect(LocalProject.directory.path, Directory.current.path);
    });
    test('field: name', () {
      expect(LocalProject.name, 'documentation_builder');
    });
  });
}
