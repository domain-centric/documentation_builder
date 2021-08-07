import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('class: PubDevProject', () {
    test('field: uri', () {
      var uri = PubDevProject().uri;
      expect(uri.toString(), 'https://pub.dev/packages/documentation_builder');
      //TODO test if uri exists
    });
    test('getter method: changeLogUri', () {
      var uri = PubDevProject().changeLogUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/changelog');
      //TODO test if uri exists
    });
    test('getter method: exampleUri', () {
      var uri = PubDevProject().exampleUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/example');
      //TODO test if uri exists
    });
    test('getter method: installUri', () {
      var uri = PubDevProject().installUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/install');
      //TODO test if uri exists
    });
    test('getter method: versionsUri', () {
      var uri = PubDevProject().versionsUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/versions');
      //TODO test if uri exists
    });
    test('getter method: scoreUri', () {
      var uri = PubDevProject().scoreUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/score');
      //TODO test if uri exists
    });
    test('getter method: licenseUri', () {
      var uri = PubDevProject().licenseUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/license');
      //TODO test if uri exists
    });
  });
}
