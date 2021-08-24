import 'package:documentation_builder/project/github_project.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

main() {
  group('class: GitHubProject', () {
    test('get method: uri', () async {
      expect(GitHubProject().uri.toString(),
          'https://github.com/efficientyboosters/documentation_builder');
      expect(await uriExists(GitHubProject().uri), true);
    });

    test('get method: roadMapUri', () async {
      expect(GitHubProject().roadMapUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones');
      expect(await uriExists(GitHubProject().uri), true);
    });

    test('get method: versionsUri', () async {
      expect(GitHubProject().versionsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones%3Fstate=closed');
      expect(await uriExists(GitHubProject().uri), true);
    });

    test('get method: pullRequestsUri', () async {
      expect(GitHubProject().pullRequestsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/pulls');
      expect(await uriExists(GitHubProject().uri), true);
    });

    test('get method: wikiUri', () async {
      expect(GitHubProject().wikiUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/wiki');
      expect(await uriExists(GitHubProject().uri), true);
    });
    test('method: searchUri', () async {
      expect(GitHubProject().searchUri('Test').toString(),
          'https://github.com/efficientyboosters/documentation_builder/search%3Fq=Test');
      expect(await uriExists(GitHubProject().uri), true);
    });
  });
}

Future<bool> uriExists(Uri? uri) async {
  if (uri == null) return false;
  var response = await http.get(uri);
  var success = response.statusCode >= 200 && response.statusCode < 300;
  return success;
}
