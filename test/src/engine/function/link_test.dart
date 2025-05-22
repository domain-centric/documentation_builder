import 'package:documentation_builder/src/engine/function/link.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/project/pub_dev_project.dart';
import 'package:documentation_builder/src/engine/template_engine.dart';
import 'package:template_engine/template_engine.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('LinkFunctions', () {
    test('GitHubLink returns correct MarkDownLink', () async {
      final func = GitHubLink();
      var variableMap = await createFakeVariables();
      final result = await func.function('', FakeRenderContext(variableMap), {
        TextParameter.id: 'GitHub',
        SuffixParameter.id: '/issues',
      });
      result.text.should.be('GitHub');
      result.uri.toString().should.be('https://github.com/domain-centric/documentation_builder/issues');
    });

    test('GitHubWikiLink returns correct MarkDownLink', () async {
      final func = GitHubWikiLink();
      var variableMap = await createFakeVariables();
      final result = await func.function('', FakeRenderContext(variableMap), {
        TextParameter.id: 'Wiki',
        SuffixParameter.id: '/Home',
      });
      result.text.should.be('Wiki');
      result.uri.toString().should.be('https://github.com/domain-centric/documentation_builder/wiki/Home');
    });

    test('parsing {{gitHubRawLink()}} should report: suffix missing', () async {
      var engine = DocumentationTemplateEngine();
      var parseResult = await engine.parseText('{{gitHubRawLink()}}');
      parseResult.errorMessage.should.be(
        "Parse error in: '{{gitHubRawLink()}}':\n"
        "  1:17: missing argument for parameter: suffix",
      );
    });

    test('PubDevLink returns correct MarkDownLink', () async {
      final func = PubDevLink();
      var variableMap = await createFakeVariables();
      final result = await func.function('', FakeRenderContext(variableMap), {
        TextParameter.id: 'PubDev',
        SuffixParameter.id: '/changelog',
      });
      result.text.should.be('PubDev');
      result.uri.toString().should.be('https://pub.dev/packages/documentation_builder/changelog');
    });

    test('ReferenceLink throws on unknown reference', () async {
      final func = ReferenceLink();
      var variableMap = await createFakeVariables();
      try {
        await func.function('', FakeRenderContext(variableMap), {
          ReferenceLink.refId: 'not_a_real_ref',
        });
      } catch (e) {
        e.should.beOfType<ArgumentError>().toString().should.be(
          "Invalid argument(s) (ref): 'not_a_real_ref' could not be "
          "translated to an existing address on the internet",
        );
      }
    });

    test('ReferenceLink returns MarkDownLink for valid URL', () async {
      final func = ReferenceLink();
      final result = await func.function('', FakeRenderContext(VariableMap()), {
        ReferenceLink.refId: 'https://www.google.com',
        TextParameter.id: 'Google',
      });
      result.text.should.be('Google');
      result.uri.toString().should.be('https://www.google.com');
    });

    test('PubDevLicenseLink returns correct MarkDownLink', () async {
      final func = PubDevLicenseLink();
      var variableMap = await createFakeVariables();
      final result = await func.function('', FakeRenderContext(variableMap), {
        TextParameter.id: 'License',
      });
      result.text.should.be('License');
      result.uri.toString().should.be('https://pub.dev/packages/documentation_builder/license');
    });
  });
}

Future<VariableMap> createFakeVariables() async => <String, Object>{
  GitHubProject.id: await GitHubProject.createForThisProject(),
  PubDevProject.id: await PubDevProject.createForThisProject(),
};

class FakeRenderContext extends RenderContext {
  FakeRenderContext(VariableMap variables)
    : super(
        engine: DocumentationTemplateEngine(),
        parsedTemplates: [],
        templateBeingRendered: TextTemplate('test'),
        variables: variables,
      );
}
