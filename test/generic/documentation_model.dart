import 'package:documentation_builder/src/builder/documentation_model_builder.dart';
import 'package:documentation_builder/src/generic/documentation_model.dart';
import 'package:documentation_builder/src/generic/paths.dart';
import 'package:test/test.dart';

main() {
  group('class: DocumentationModel', () {
    group('method: findOrderedMarkdownTemplateFiles', () {
      test("finds templates in correct order (wiki's first)", () {
        var model = TestDocumentationModel();
        var templates = model.findOrderedMarkdownTemplates();
        expect(templates.length, 2);
        expect(templates.first is WikiTemplate, true);
        expect(templates.last is ReadMeTemplate, true);
      });
    });
  });
}

class TestDocumentationModel extends DocumentationModel {
  TestDocumentationModel() {
    children.add(createReadMeTemplate());
    children.add(createWikiTemplate());
  }

  Template createReadMeTemplate() => ReadMeTemplateFactory()
      .createDocument(this, ProjectFilePath('doc/template/README.mdt'));

  Template createWikiTemplate() => WikiTemplateFactory().createDocument(
      this, ProjectFilePath('doc/template/01-Documentation-Builder.md'));
}
