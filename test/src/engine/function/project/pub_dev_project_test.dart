import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

main() {
  group('class: PubDevProject', () {
    late PubDevProject pubDevProject;
    setUp(() async {
      pubDevProject = await PubDevProject.createForThisProject();
    });
    test('field: uri', () async {
      pubDevProject.uri.should.not.beNull();
      pubDevProject.uri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder');
      (await pubDevProject.uri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: changeLogUri', () async {
      pubDevProject.changeLogUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/changelog');
      (await pubDevProject.changeLogUri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: exampleUri', () async {
      pubDevProject.exampleUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/example');
      (await pubDevProject.exampleUri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: installUri', () async {
      pubDevProject.installUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/install');
      (await pubDevProject.installUri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: versionsUri', () async {
      pubDevProject.versionsUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/versions');
      (await pubDevProject.versionsUri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: scoreUri', () async {
      pubDevProject.scoreUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/score');
      (await pubDevProject.scoreUri.canGetWithHttp()).should.beTrue();
    });
    test('getter method: licenseUri', () async {
      pubDevProject.licenseUri
          .toString()
          .should
          .be('https://pub.dev/packages/documentation_builder/license');
      (await pubDevProject.licenseUri.canGetWithHttp()).should.beTrue();
    });
  });
}
