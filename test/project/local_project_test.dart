import 'dart:io';

import 'package:documentation_builder/project/local_project.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('class: LocalProject', () {
    test('field: directory', () {
      expect(LocalProject().directory.path, Directory.current.path);
    });
    test('field: name', () {
      expect(LocalProject().name, 'documentation_builder');
    });
    // test('getter method: readMeFile', () {
    //   expect(LocalProject().readMeFile.path.endsWith('documentation_builder${Platform.pathSeparator}README.md'), true);
    // });
    // test('getter method: changeLogFile', () {
    //   expect(LocalProject().changeLogFile.path.endsWith('documentation_builder${Platform.pathSeparator}CHANGELOG.md'), true);
    // });
    // test('getter method: exampleFile', () {
    //   expect(LocalProject().exampleFile.path.endsWith('documentation_builder${Platform.pathSeparator}example${Platform.pathSeparator}example.md'), true);
    // });
    // test('getter method: exampleFile', () {
    //   expect(LocalProject().wikiFile('Home.md').path.endsWith('documentation_builder${Platform.pathSeparator}doc${Platform.pathSeparator}wiki${Platform.pathSeparator}Home.md'), true);
    // });
  });
}
