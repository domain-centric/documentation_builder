import 'package:documentation_builder/project/pub_dev_project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

main() {
  group('class: PubDevProject', () {
    test('field: uri', () async {
      var uri = PubDevProject().uri;
      expect(uri.toString(), 'https://pub.dev/packages/documentation_builder');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: changeLogUri', () async {
      var uri = PubDevProject().changeLogUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/changelog');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: exampleUri', () async {
      var uri = PubDevProject().exampleUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/example');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: installUri', () async {
      var uri = PubDevProject().installUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/install');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: versionsUri', () async {
      var uri = PubDevProject().versionsUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/versions');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: scoreUri', () async {
      var uri = PubDevProject().scoreUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/score');
      expect(await uriExists(PubDevProject().uri), true);
    });
    test('getter method: licenseUri', () async {
      var uri = PubDevProject().licenseUri;
      expect(uri.toString(),
          'https://pub.dev/packages/documentation_builder/license');
      expect(await uriExists(PubDevProject().uri), true);
    });
  });
}

Future<bool> uriExists(Uri? uri) async {
  if (uri == null) return false;
  var response = await http.get(uri);
  var success = response.statusCode >= 200 && response.statusCode < 300;
  return success;
}
