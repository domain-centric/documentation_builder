import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:test/test.dart';

main() {
  group('class: GitHubProject', () {
    late GitHubProject gitHubProject;
    setUp(() async {
      gitHubProject = await GitHubProject.createForThisProject();
    });

    test('get method: uri', () async {
      expect(gitHubProject.uri.toString(),
          'https://github.com/domain-centric/documentation_builder');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });

    test('get method: roadMapUri', () async {
      expect(gitHubProject.milestonesUri.toString(),
          'https://github.com/domain-centric/documentation_builder/milestones');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });

    test('get method: versionsUri', () async {
      expect(gitHubProject.releasesUri.toString(),
          'https://github.com/domain-centric/documentation_builder/releases');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });

    test('get method: pullRequestsUri', () async {
      expect(gitHubProject.pullRequestsUri.toString(),
          'https://github.com/domain-centric/documentation_builder/pulls');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });

    test('get method: wikiUri', () async {
      expect(gitHubProject.wikiUri.toString(),
          'https://github.com/domain-centric/documentation_builder/wiki');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });
    test('method: searchUri', () async {
      expect(gitHubProject.searchUri('Test').toString(),
          'https://github.com/domain-centric/documentation_builder/search?q=Test');
      expect(await gitHubProject.uri.canGetWithHttp(), true);
    });
    test('method: rawUri', () async {
      expect(gitHubProject.rawUri.toString(),
          'https://raw.githubusercontent.com/domain-centric/documentation_builder');
      expect(
          await gitHubProject.rawUri
              .append(path: 'main/README.md')
              .canGetWithHttp(),
          true);
    });
    test('method: stargazersUri', () async {
      expect(gitHubProject.starGazersUri.toString(),
          'https://github.com/domain-centric/documentation_builder/stargazers');
      expect(await gitHubProject.starGazersUri.canGetWithHttp(), true);
    });
    test('method: issuesUri', () async {
      expect(gitHubProject.issuesUri.toString(),
          'https://github.com/domain-centric/documentation_builder/issues');
      expect(await gitHubProject.issuesUri.canGetWithHttp(), true);
    });

    test('method: dartFile', () async {
      Uri uri = gitHubProject
          .sourceFileUri(ProjectFilePath2('lib/src/parser/link_parser.dart'));
      expect(
          uri,
          Uri.parse(
              'https://github.com/domain-centric/documentation_builder/blob/main/lib/src/parser/link_parser.dart'));
      expect(await uri.canGetWithHttp(), true);
    });
  });
}
