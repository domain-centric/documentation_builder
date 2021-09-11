import 'package:documentation_builder/builder/template_builder.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:test/test.dart';

main() {
  group('class: DocumentationModel', () {
    group('method: findOrderedMarkdownTemplateFiles', () {
      test("finds templates in correct order (wiki's first)", () {
        var model=TestDocumentationModel();
        var templates=model.findOrderedMarkdownTemplateFiles();
        expect (templates.length,2);
        expect (templates.first.factory,equals(WikiFactory()));
        expect (templates.last.factory,equals(ReadMeFactory()));
      });
    });
  });
}

class TestDocumentationModel extends DocumentationModel {

  TestDocumentationModel() {
    children.add(createReadMeTemplate());
    children.add(createWikiTemplate());
  }

  MarkdownTemplate createReadMeTemplate() =>
      ReadMeFactory().createMarkdownTemplate(this, 'doc/template/README.mdt');

  MarkdownTemplate createWikiTemplate() =>
      WikiFactory().createMarkdownTemplate(
          this, 'doc/template/01-Documentation-Builder.md');


}
