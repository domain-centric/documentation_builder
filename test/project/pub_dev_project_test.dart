import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:test/test.dart';

main() {
  group('class: PubDevProject', () {
    test('field: uri', () async {
      expect(PubDevProject().uri!.toString(),
          'https://pub.dev/packages/documentation_builder');
      expect(await PubDevProject().uri!.canGetWithHttp(), true);
    });
    test('getter method: changeLogUri', () async {
      expect(PubDevProject().changeLogUri!.toString(),
          'https://pub.dev/packages/documentation_builder/changelog');
      expect(await PubDevProject().changeLogUri!.canGetWithHttp(), true);
    });
    test('getter method: exampleUri', () async {
      expect(PubDevProject().exampleUri!.toString(),
          'https://pub.dev/packages/documentation_builder/example');
      expect(await PubDevProject().exampleUri!.canGetWithHttp(), true);
    });
    test('getter method: installUri', () async {
      expect(PubDevProject().installUri!.toString(),
          'https://pub.dev/packages/documentation_builder/install');
      expect(await PubDevProject().installUri!.canGetWithHttp(), true);
    });
    test('getter method: versionsUri', () async {
      expect(PubDevProject().versionsUri!.toString(),
          'https://pub.dev/packages/documentation_builder/versions');
      expect(await PubDevProject().versionsUri!.canGetWithHttp(), true);
    });
    test('getter method: scoreUri', () async {
      expect(PubDevProject().scoreUri!.toString(),
          'https://pub.dev/packages/documentation_builder/score');
      expect(await PubDevProject().scoreUri!.canGetWithHttp(), true);
    });
    test('getter method: licenseUri', () async {
      expect(PubDevProject().licenseUri!.toString(),
          'https://pub.dev/packages/documentation_builder/license');
      expect(await PubDevProject().licenseUri!.canGetWithHttp(), true);
    });
  });
}
