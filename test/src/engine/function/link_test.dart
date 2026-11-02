import 'package:documentation_builder/src/engine/function/link.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

import 'util/reference_test.dart';

void main() {
  group('LinkFunctions', () {
    test('GitHubLink returns correct MarkDownLink', () async {
      final func = gitHubLinkFunction;
      var variableMap = await createFakeVariables();
      var argumentValues = {
        TextParameter.id: 'GitHub',
        SuffixParameter.id: '/issues',
      };
      final result = await func.function(
        FakeFunctionCallContext(
          FakeRenderContext(variableMap),
          argumentValues: argumentValues,
        ),
      );
      result.toString().should.be(
        '[GitHub](https://github.com/domain-centric/documentation_builder/issues)',
      );
    });

    test('GitHubWikiLink returns correct MarkDownLink', () async {
      final func = gitHubWikiLinkFunction;
      var variableMap = await createFakeVariables();
      var argumentValues = {
        TextParameter.id: 'Wiki',
        SuffixParameter.id: '/Home',
      };
      final result = await func.function(
        FakeFunctionCallContext(
          FakeRenderContext(variableMap),
          argumentValues: argumentValues,
        ),
      );
      result.toString().should.be(
        '[Wiki](https://github.com/domain-centric/documentation_builder/wiki/Home)',
      );
    });

    test('parsing {{gitHubRawLink()}} should report: suffix missing', () async {
      var engine = DocumentationTemplateEngine();
      var parseResult = await engine.parseText('{{gitHubRawLink()}}');
      parseResult.aggregatedErrorMessage.should.be(
        "Error in: {{gitHubRawLink()}}\n"
        "  Parse error:\n"
        "    1:17 - Missing argument for parameter: suffix",
      );
    });

    test('PubDevLink returns correct MarkDownLink', () async {
      final func = pubDevLinkFunction;
      var variableMap = await createFakeVariables();
      var argumentValues = {
        TextParameter.id: 'PubDev',
        SuffixParameter.id: '/changelog',
      };
      var fakeFunctionCallContext = FakeFunctionCallContext(
        FakeRenderContext(variableMap),
        argumentValues: argumentValues,
      );
      final result = await func.function(fakeFunctionCallContext);
      result.toString().should.be(
        '[PubDev](https://pub.dev/packages/documentation_builder/changelog)',
      );
    });

    test('ReferenceLink throws on unknown reference', () async {
      final func = referenceLinkFunction;
      var variableMap = await createFakeVariables();
      try {
        var argumentValues = {LinkFunctionArgumentName.ref: 'not_a_real_ref'};
        var fakeFunctionCallContext = FakeFunctionCallContext(
          FakeRenderContext(variableMap),
          argumentValues: argumentValues,
        );
        await func.function(fakeFunctionCallContext);
      } catch (e) {
        e.should.beOfType<ArgumentError>().toString().should.be(
          "Invalid argument(s) (ref): 'not_a_real_ref' could not be "
          "translated to an existing address on the internet",
        );
      }
    });

    test('ReferenceLink returns MarkDownLink for valid URL', () async {
      final func = referenceLinkFunction;
      var argumentValues = {
        LinkFunctionArgumentName.ref: 'https://www.google.com',
        TextParameter.id: 'Google',
      };
      var fakeFunctionCallContext = FakeFunctionCallContext(
        FakeRenderContext({}),
        argumentValues: argumentValues,
      );
      final result = await func.function(fakeFunctionCallContext);
      result.toString().should.be('[Google](https://www.google.com)');
    });

    test('PubDevLicenseLink returns correct MarkDownLink', () async {
      final func = pubDevLicenseLinkFunction;
      var variableMap = await createFakeVariables();
      var argumentValues = {TextParameter.id: 'License'};
      var fakeFunctionCallContext = FakeFunctionCallContext(
        FakeRenderContext(variableMap),
        argumentValues: argumentValues,
      );
      final result = await func.function(fakeFunctionCallContext);
      result.toString().should.be(
        '[License](https://pub.dev/packages/documentation_builder/license)',
      );
    });
  });
}

Future<VariableMap> createFakeVariables() async => <String, Object>{
  GitHubProject.id: await GitHubProject.createForThisProject(),
  PubDevProject.id: await PubDevProject.createForThisProject(),
};
