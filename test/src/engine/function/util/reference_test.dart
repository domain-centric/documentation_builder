import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';
import 'package:documentation_builder/src/engine/function/util/reference.dart';

void main() {
  group('MarkDownLink', () {
    test('should create a MarkDownLink with correct values', () {
      final link = MarkDownLink('Google', Uri.parse('https://google.com'));
      link.text.should.be('Google');
      link.uri.should.be(Uri.parse('https://google.com'));
    });

    test('should convert MarkDownLink to string correctly', () {
      final link = MarkDownLink('Google', Uri.parse('https://google.com'));
      link.toString().should.be('[Google](https://google.com)');
    });
  });

  group('UrlMarkDownLinkFactory', () {
    late UrlMarkDownLinkFactory factory;
    late RenderContext context;
    setUp(() async {
      factory = UrlMarkDownLinkFactory();
      var variables = <String, Object>{
        GitHubProject.id: await GitHubProject.createForThisProject(),
      };
      context = FakeRenderContext(variables);
    });
    test('should create MarkDownLink for valid http url', () async {
      final link = await factory.create(
        context: context,
        reference: 'https://example.com',
      );
      link.should.not.beNull();
      link!.text.should.be('example.com');
      link.uri.should.be(Uri.parse('https://example.com'));
    });

    test('should return null for invalid url', () async {
      final link = await factory.create(
        context: context,
        reference: 'not a url',
      );
      link.should.beNull();
    });
  });

  group('MarkDownLinkFactories', () {
    late MarkDownLinkFactories factories;
    late RenderContext context;
    setUp(() async {
      factories = MarkDownLinkFactories();
      var variables = <String, Object>{
        GitHubProject.id: await GitHubProject.createForThisProject(),
      };
      context = FakeRenderContext(variables);
    });
    test('should return first non-null MarkDownLink', () async {
      final link = await factories.create(
        context: context,
        reference: 'https://example.com',
      );
      link.should.not.beNull();
      link!.uri.should.be(Uri.parse('https://example.com'));
    });

    test('should an invalid reference should throw an exception ', () async {
      await Should.throwAsync<Exception>(
        () async => await factories.create(
          context: context,
          reference: 'not a url and not a package',
        ),
      );
    });
  });

  group('SourceLinkFactory', () {
    test('should return null for non-existent source path', () async {
      final factory = SourceLinkFactory();
      final variables = <String, Object>{
        GitHubProject.id: await GitHubProject.createForThisProject(),
      };
      final context = FakeRenderContext(variables);
      final link = await factory.create(
        context: context,
        reference: 'non/existent/path.dart',
      );
      link.should.beNull();
    });

    test('getParameterFromYaml returns correct value', () {
      final factory = SourceLinkFactory();
      final yaml = 'name: test, version: 1.0.0, description: desc, author: me,';
      final value = factory.getParameterFromYaml(yaml, 'version');
      value.should.be('1.0.0');
    });

    test('getParameterFromYaml returns null if parameter not found', () {
      final factory = SourceLinkFactory();
      final yaml = 'name: test, version: 1.0.0,';
      final value = factory.getParameterFromYaml(yaml, 'notfound');
      value.should.beNull();
    });
  });
}

/// Fake RenderContext for testing purposes
class FakeRenderContext implements RenderContext {
  @override
  final VariableMap variables;

  FakeRenderContext(this.variables);

  @override
  TemplateEngine get engine => throw UnimplementedError();

  @override
  List<TemplateParseResult> get parsedTemplates => throw UnimplementedError();

  @override
  String get renderedError => throw UnimplementedError();

  @override
  Template get templateBeingRendered => throw UnimplementedError();
}
