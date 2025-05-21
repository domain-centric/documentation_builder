import 'dart:io';

import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('class: LocalProject', () {
    test('field: directory', () {
      LocalProject.directory.path.should.be(Directory.current.path);
    });
    test('field: name', () {
      LocalProject.name.should.be('documentation_builder');
    });
  });
}
