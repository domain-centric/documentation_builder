// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:shouldly/shouldly.dart';
import 'package:build/build.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';
import 'package:crypto/src/digest.dart';
import 'package:documentation_builder/documentation_builder.dart';
import 'package:glob/glob.dart';
import 'package:package_config/src/package_config.dart';

void main() {
  group('DocumentationTemplateEngine path and uri functions', () {
    late DocumentationTemplateEngine engine;

    setUp(() {
      engine = DocumentationTemplateEngine();
    });

    Future<VariableMap> buildVariables() async {
      return {
        BuildStepVariable.id: FakeBuildStep(),
        GitHubProject.id: await GitHubProject.createForThisProject(),
        PubDevProject.id: await PubDevProject.createForThisProject(),
      };
    }

    Future<void> testTemplate(
      String templateExpression,
      String expectedResult,
    ) async {
      final parseResult = await engine.parseText(templateExpression);
      final vars = await buildVariables();
      final renderResult = await engine.render(parseResult, vars);
      renderResult.text.should.be(expectedResult);
    }

    group('Path functions', () {
      test('inputPath', () async {
        await testTemplate('{{inputPath()}}', 'lib/input_file.md');
      });

      test('outputPath', () async {
        await testTemplate('{{outputPath()}}', 'lib/output_file.md');
      });

      test('templateSource', () async {
        await testTemplate('{{templateSource()}}', "'{{templateSource()}}'");
      });
    });

    group('GitHub functions', () {
      test('gitHubUri', () async {
        await testTemplate(
          '{{gitHubUri()}}',
          'https://github.com/domain-centric/documentation_builder',
        );
      });

      test('gitHubWikiUri', () async {
        await testTemplate(
          '{{gitHubWikiUri()}}',
          'https://github.com/domain-centric/documentation_builder/wiki',
        );
      });

      test('gitHubStarsUri', () async {
        await testTemplate(
          '{{gitHubStarsUri()}}',
          'https://github.com/domain-centric/documentation_builder/stargazers',
        );
      });

      test('gitHubIssuesUri', () async {
        await testTemplate(
          '{{gitHubIssuesUri()}}',
          'https://github.com/domain-centric/documentation_builder/issues',
        );
      });

      test('gitHubMilestonesUri', () async {
        await testTemplate(
          '{{gitHubMilestonesUri()}}',
          'https://github.com/domain-centric/documentation_builder/milestones',
        );
      });

      test('gitHubReleasesUri', () async {
        await testTemplate(
          '{{gitHubReleasesUri()}}',
          'https://github.com/domain-centric/documentation_builder/releases',
        );
      });

      test('gitHubPullRequestsUri', () async {
        await testTemplate(
          '{{gitHubPullRequestsUri()}}',
          'https://github.com/domain-centric/documentation_builder/pulls',
        );
      });

      test('gitHubRawUri', () async {
        await testTemplate(
          "{{gitHubRawUri('test/src/engine/function/path_test.dart')}}",
          'https://raw.githubusercontent.com/domain-centric/documentation_builder/refs/heads/maintest/src/engine/function/path_test.dart',
        );
      });
    });

    group('PubDev functions', () {
      test('pubDevUri', () async {
        await testTemplate(
          '{{pubDevUri()}}',
          'https://pub.dev/packages/documentation_builder',
        );
      });

      test('pubDevChangeLogUri', () async {
        await testTemplate(
          '{{pubDevChangeLogUri()}}',
          'https://pub.dev/packages/documentation_builder/changelog',
        );
      });

      test('pubDevVersionsUri', () async {
        await testTemplate(
          '{{pubDevVersionsUri()}}',
          'https://pub.dev/packages/documentation_builder/versions',
        );
      });

      test('pubDevExampleUri', () async {
        await testTemplate(
          '{{pubDevExampleUri()}}',
          'https://pub.dev/packages/documentation_builder/example',
        );
      });

      test('pubDevInstallUri', () async {
        await testTemplate(
          '{{pubDevInstallUri()}}',
          'https://pub.dev/packages/documentation_builder/install',
        );
      });

      test('pubDevScoreUri', () async {
        await testTemplate(
          '{{pubDevScoreUri()}}',
          'https://pub.dev/packages/documentation_builder/score',
        );
      });

      test('pubDevLicenseUri', () async {
        await testTemplate(
          '{{pubDevLicenseUri()}}',
          'https://pub.dev/packages/documentation_builder/license',
        );
      });

      test('referenceUri', () async {
        await testTemplate(
          "{{referenceUri('documentation_builder')}}",
          'https://pub.dev/packages/documentation_builder',
        );
      });
    });
  });
}

// ignore: subtype_of_sealed_class
class FakeBuildStep extends BuildStep {
  @override
  AssetId get inputId => AssetId('test_package', 'lib/input_file.md');

  @override
  List<AssetId> get allowedOutputs => [
    AssetId('test_package', 'lib/output_file.md'),
  ];

  @override
  Future<void> writeAsString(
    AssetId id,
    FutureOr<String> content, {
    Encoding encoding = utf8,
  }) async {}

  @override
  Future<bool> canRead(AssetId id) {
    throw UnimplementedError();
  }

  @override
  Future<Digest> digest(AssetId id) {
    throw UnimplementedError();
  }

  @override
  Future<T> fetchResource<T>(Resource<T> resource) {
    throw UnimplementedError();
  }

  @override
  Stream<AssetId> findAssets(Glob glob) {
    throw UnimplementedError();
  }

  @override
  Future<LibraryElement> get inputLibrary => throw UnimplementedError();

  @override
  Future<PackageConfig> get packageConfig => throw UnimplementedError();

  @override
  Future<List<int>> readAsBytes(AssetId id) {
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  void reportUnusedAssets(Iterable<AssetId> ids) {}

  @override
  Resolver get resolver => throw UnimplementedError();

  @override
  T trackStage<T>(
    String label,
    T Function() action, {
    bool isExternal = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> writeAsBytes(AssetId id, FutureOr<List<int>> bytes) {
    throw UnimplementedError();
  }
}
