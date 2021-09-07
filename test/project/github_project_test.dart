import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/generic/paths.dart';
import 'package:test/test.dart';


main() {
  group('class: GitHubProject', () {
    test('get method: uri', () async {
      expect(GitHubProject().uri.toString(),
          'https://github.com/efficientyboosters/documentation_builder');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });

    test('get method: roadMapUri', () async {
      expect(GitHubProject().milestonesUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });

    test('get method: versionsUri', () async {
      expect(GitHubProject().versionsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones%3Fstate=closed');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });

    test('get method: pullRequestsUri', () async {
      expect(GitHubProject().pullRequestsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/pulls');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });

    test('get method: wikiUri', () async {
      expect(GitHubProject().wikiUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/wiki');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });
    test('method: searchUri', () async {
      expect(GitHubProject().searchUri('Test').toString(),
          'https://github.com/efficientyboosters/documentation_builder/search%3Fq=Test');
      expect(await GitHubProject().uri!.canGetWithHttp(), true);
    });
  });
}


