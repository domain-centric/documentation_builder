import 'package:documentation_builder/project/github_project.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('class: GitHubProject', () {
    test('get method: uri', () {
      expect(GitHubProject().uri.toString(),
          'https://github.com/efficientyboosters/documentation_builder');
      //TODO test if uri exists
    });

    test('get method: roadMapUri', () {
      expect(GitHubProject().roadMapUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones');
      //TODO test if uri exists
    });

    test('get method: versionsUri', () {
      expect(GitHubProject().versionsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/milestones%3Fstate=closed');
      //TODO test if uri exists
    });

    test('get method: pullRequestsUri', () {
      expect(GitHubProject().pullRequestsUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/pulls');
      //TODO test if uri exists
    });

    test('get method: wikiUri', () {
      expect(GitHubProject().wikiUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/wiki');
      //TODO test if uri exists
    });
    test('method: searchUri', () {
      expect(GitHubProject().searchUri('Test').toString(),
          'https://github.com/efficientyboosters/documentation_builder/search%3Fq=Test');
      //TODO test if uri exists
    });
  });
}