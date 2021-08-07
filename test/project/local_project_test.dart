import 'dart:io';

import 'package:documentation_builder/project/local_project.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('class: LocalProject', ()
  {
    test('field: directory', () {
      expect(LocalProject().directory.path,
          Directory.current.path);
    });
    test('field: name', () {
      expect(LocalProject().name,
          'documentation_builder');
    });
  });
  }