import 'package:documentation_builder/parser/parser.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:test/test.dart';

const letterSymbol='@';
const digitSymbol='#';
const prefixSymbol='^';
const suffixSymbol='%';

main() {
  group('class: Parser', () {
    test('letter', () {
      var rootNode = RootNodeWithTextNode('a');
      var parser = LetterDigitParser();
      expect(parser.parse(rootNode).children, [
        TextNode(rootNode, letterSymbol),
      ]);
    });
    test('prefix, letter', () {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}a');
      var parser = LetterDigitParser();
      expect(parser.parse(rootNode).children, [
        TextNode(rootNode, prefixSymbol),
        TextNode(rootNode, letterSymbol),
      ]);
    });
    test('letter, suffix', () {
      var rootNode = RootNodeWithTextNode('a$suffixSymbol');
      var parser = LetterDigitParser();
      expect(parser.parse(rootNode).children, [
        TextNode(rootNode, letterSymbol),
        TextNode(rootNode, '%'),
      ]);
    });
    test('prefix, letter, suffix node', () {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}a$suffixSymbol');
      var parser = LetterDigitParser();
      expect(parser.parse(rootNode).children, [
        TextNode(rootNode, prefixSymbol),
        TextNode(rootNode, letterSymbol),
        TextNode(rootNode, suffixSymbol),
      ]);
    });
    test('prefix, digit, letter, digit, suffix', () {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}1a3$suffixSymbol');
      var parser = LetterDigitParser();
      expect(parser.parse(rootNode).children, [
        TextNode(rootNode, prefixSymbol),
        TextNode(rootNode, digitSymbol),
        TextNode(rootNode, letterSymbol),
        TextNode(rootNode, digitSymbol),
        TextNode(rootNode, suffixSymbol),

      ]);
    });
  });
}

class LetterParserRule extends TextParserRule {
  LetterParserRule() : super(FluentRegex().letter());

  @override
  Node createReplacementNode(ParentNode parent, String textToReplace) =>
      TextNode(parent, letterSymbol);
}

class DigitParserRule extends TextParserRule {
  DigitParserRule() : super(FluentRegex().digit());

  @override
  Node createReplacementNode(ParentNode parent, String textToReplace) =>
      TextNode(parent, digitSymbol);
}

class LetterDigitParser extends Parser {
  LetterDigitParser()
      : super([
          LetterParserRule(),
          DigitParserRule(),
        ]);
}

class RootNodeWithTextNode extends RootNode {
  RootNodeWithTextNode(String text) {
    children.add(TextNode(this, text));
  }
}
