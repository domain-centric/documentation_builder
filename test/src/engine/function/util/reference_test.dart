import 'dart:io';

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
    setUp(() {
      factory = UrlMarkDownLinkFactory();
      context = FakeRenderContext({});
    });
    test('should create MarkDownLink for valid http url', () async {
      final uri = await startTestServer();
      final link = await factory.create(
        context: context,
        reference: uri.toString(),
      );
      link.should.not.beNull();
      link!.text.should.be(uri.host);
      link.uri.should.be(uri);
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
    setUp(() {
      factories = MarkDownLinkFactories();
      context = FakeRenderContext({});
    });
    test('should return first non-null MarkDownLink', () async {
      final uri = await startTestServer();
      final link = await factories.create(
        context: context,
        reference: uri.toString(),
      );
      link.should.not.beNull();
      link!.uri.should.be(uri);
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

Future<Uri> startTestServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) => request.response.close());
  addTearDown(() => server.close(force: true));
  return Uri(
    scheme: 'http',
    host: InternetAddress.loopbackIPv4.address,
    port: server.port,
  );
}

/// Fake RenderContext for testing purposes
class FakeRenderContext implements RenderContext {
  @override
  final VariableMap variables;

  FakeRenderContext(this.variables);

  @override
  String get errorPlaceholder => throw UnimplementedError();

  @override
  List<TemplateEngineException> get errors => throw UnimplementedError();

  @override
  Grammar get grammar => throw UnimplementedError();

  @override
  ParseResult get parseResult => throw UnimplementedError();

  @override
  Set<ParseResult> get parsedImportedTemplates => throw UnimplementedError();
}

class FakeFunctionCallContext implements FunctionCallContext {
  @override
  void addWarning(String message, TemplateLocation location) {}

  @override
  Map<String, TemplateLocation> get argumentLocations =>
      throw UnimplementedError();

  @override
  final Map<String, dynamic> argumentValues;

  @override
  TemplateLocation get functionLocation => throw UnimplementedError();

  @override
  final RenderContext renderContext;

  FakeFunctionCallContext(this.renderContext, {this.argumentValues = const {}});
}
