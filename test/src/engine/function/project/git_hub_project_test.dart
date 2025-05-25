import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('class: GitHubProject', () {
    late GitHubProject gitHubProject;
    setUp(() async {
      gitHubProject = await GitHubProject.createForThisProject();
    });

    test('get method: uri', () async {
      gitHubProject.uri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder',
      );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });

    test('get method: roadMapUri', () async {
      gitHubProject.milestonesUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/milestones',
      );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });

    test('get method: versionsUri', () async {
      gitHubProject.releasesUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/releases',
      );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });

    test('get method: pullRequestsUri', () async {
      gitHubProject.pullRequestsUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/pulls',
      );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });

    test('get method: wikiUri', () async {
      gitHubProject.wikiUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/wiki',
      );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });
    test('method: searchUri', () async {
      gitHubProject
          .searchUri('Test')
          .toString()
          .should
          .be(
            'https://github.com/domain-centric/documentation_builder/search?q=Test',
          );
      (await gitHubProject.uri.canGetWithHttp()).should.beTrue();
    });
    test('method: rawUri', () async {
      gitHubProject.rawUri.toString().should.be(
        'https://raw.githubusercontent.com/domain-centric/documentation_builder/refs/heads/main',
      );
    });
    test('method: stargazersUri', () async {
      gitHubProject.starGazersUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/stargazers',
      );
      (await gitHubProject.starGazersUri.canGetWithHttp()).should.beTrue();
    });
    test('method: issuesUri', () async {
      gitHubProject.issuesUri.toString().should.be(
        'https://github.com/domain-centric/documentation_builder/issues',
      );
      (await gitHubProject.issuesUri.canGetWithHttp()).should.beTrue();
    });

    test('method: dartFile', () async {
      Uri uri = gitHubProject.sourceFileUri(
        ProjectFilePath2('lib/src/builder/documentation_builder.dart'),
      );
      uri.should.be(
        Uri.parse(
          'https://github.com/domain-centric/documentation_builder/blob/main/lib/src/builder/documentation_builder.dart',
        ),
      );
      (await uri.canGetWithHttp()).should.beTrue();
    });
  });
}
