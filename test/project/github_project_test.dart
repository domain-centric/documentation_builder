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
      expect(GitHubProject().releasesUri.toString(),
          'https://github.com/efficientyboosters/documentation_builder/releases');
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
    test('method: rawUri', () async {
      expect(GitHubProject().rawUri.toString(),
          'https://raw.githubusercontent.com/efficientyboosters/documentation_builder');
      expect(await GitHubProject().rawUri!
          .withPathSuffix('main/README.md').canGetWithHttp(), true);
    });

    test('method: dartFile', () async {
      Uri uri = GitHubProject().dartFile(DartFilePath('lib/parser/link_parser.dart'))!;
      expect(uri,
          Uri.parse('https://github.com/efficientyboosters/documentation_builder/blob/main/lib/parser/link_parser.dart'));
      expect(await uri.canGetWithHttp(),true);
    });
  });
}


