import 'package:documentation_builder/src/engine/function/util/table_of_contents.dart';
import 'package:petitparser/petitparser.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('TitleLink', () {
    test('createFragmentFromTitle generates correct fragment', () {
      TitleLink.createFragmentFromTitle(
        'My Awesome Title!',
      ).should.be('my-awesome-title');
      TitleLink.createFragmentFromTitle(
        'Title   With   Spaces',
      ).should.be('title-with-spaces');
      TitleLink.createFragmentFromTitle(
        'Title_with_underscores',
      ).should.be('title_with_underscores');
      TitleLink.createFragmentFromTitle(
        'Title-with-dashes',
      ).should.be('title-with-dashes');
      TitleLink.createFragmentFromTitle(
        'Title: Special #Chars!',
      ).should.be('title-special-chars');
    });

    test('createTitleFromRelativePath removes extension and formats', () {
      TitleLink.createTitleFromRelativePath(
        'my-file_name.md',
      ).should.be('my file name');
      TitleLink.createTitleFromRelativePath(
        'another-file.txt',
      ).should.be('another file');
      TitleLink.createTitleFromRelativePath(
        'complex-file_name.test.md',
      ).should.be('complex file name');
    });

    test('toBold wraps text in bold markdown', () {
      TitleLink.toBold('Hello').should.be('**Hello**');
    });

    test('markDown property formats correctly', () {
      final link = TitleLink(relativePath: 'file.md', title: 'Title', level: 2);
      link.markDown.should.be('    * [Title](file.md#title)');
    });

    test('fromFileName removes .md extension if requested', () {
      final link = TitleLink.fromFileName(
        relativePath: 'file.md',
        removeMdExtension: true,
      );
      link.relativePath.should.be('file');
      link.title.should.be('**file**');
      link.level.should.be(0);
    });
  });

  group('TableOfContentsFactory', () {
    late TableOfContentsFactory factory;

    setUp(() {
      factory = TableOfContentsFactory();
    });

    test('findTitles finds all headings in markdown', () {
      const markdown = '''
  # Title One
  Some paragraph text.
  ## Subtitle One
  ### Sub-subtitle
  Another paragraph.
  # Another Title
  This is a hashtag: # not a title
  ''';
      final titles = factory.findTitles(
        outputFileName: 'file.md',
        markDown: markdown,
        removeMdExtension: false,
      );
      titles.length.should.be(4);
      titles[0].title.should.be('Title One');
      titles[0].level.should.be(1);
      titles[1].title.should.be('Subtitle One');
      titles[1].level.should.be(2);
      titles[2].title.should.be('Sub-subtitle');
      titles[2].level.should.be(3);
      titles[3].title.should.be('Another Title');
      titles[3].level.should.be(1);
    });

    test('toListWithoutLevelGabs flattens hierarchy', () {
      final links = [
        TitleLink(relativePath: 'a.md', title: 'A', level: 0),
        TitleLink(relativePath: 'a.md', title: 'B', level: 3),
        TitleLink(relativePath: 'a.md', title: 'C', level: 3),
        TitleLink(relativePath: 'a.md', title: 'D', level: 4),
        TitleLink(relativePath: 'a.md', title: 'E', level: 2),
        TitleLink(relativePath: 'a.md', title: 'F', level: 0),
      ];
      final flat = factory.toListWithoutLevelGabs(links);
      Should.satisfyAllConditions([
        () => flat.length.should.be(6),
        () => flat[0].title.should.be('A'),
        () => flat[0].level.should.be(1),
        () => flat[1].title.should.be('B'),
        () => flat[1].level.should.be(2),
        () => flat[2].title.should.be('C'),
        () => flat[2].level.should.be(2),
        () => flat[3].title.should.be('D'),
        () => flat[3].level.should.be(3),
        () => flat[4].title.should.be('E'),
        () => flat[4].level.should.be(2),
        () => flat[5].title.should.be('F'),
        () => flat[5].level.should.be(1),
      ]);
    });
  });
  group('_markdownTitleParser', () {
    test('parses headings correctly', () {
      final parser = markdownTitleParser();
      final matches = parser.allMatches('\n# Heading 1\n## Heading 2\n');
      matches.length.should.be(2);
      matches.first.title.should.be('Heading 1');
      matches.last.title.should.be('Heading 2');
    });

    test('ignores non-heading lines', () {
      final parser = markdownTitleParser();
      final matches = parser.allMatches('\nNot a heading\n# Heading\n');
      matches.length.should.be(1);
      matches.first.title.should.be('Heading');
    });
  });
}
