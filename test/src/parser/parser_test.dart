import 'package:documentation_builder/src/parser/parser.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:test/test.dart';

const letterSymbol = '@';
const digitSymbol = '#';
const prefixSymbol = '^';
const suffixSymbol = '%';

main() {
  group('class: Parser', () {
    test('letter', () async {
      var rootNode = RootNodeWithTextNode('a');
      var parser = LetterDigitParser();
      var parsedNodes = await parser.parse(rootNode);
      expect(parsedNodes.children, [
        TextNode(rootNode, letterSymbol),
      ]);
    });
    test('prefix, letter', () async {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}a');
      var parser = LetterDigitParser();
      var parsedNode = await parser.parse(rootNode);
      expect(parsedNode.children, [
        TextNode(rootNode, prefixSymbol),
        TextNode(rootNode, letterSymbol),
      ]);
    });
    test('letter, suffix', () async {
      var rootNode = RootNodeWithTextNode('a$suffixSymbol');
      var parser = LetterDigitParser();
      var parsedNode = await parser.parse(rootNode);
      expect(parsedNode.children, [
        TextNode(rootNode, letterSymbol),
        TextNode(rootNode, '%'),
      ]);
    });
    test('prefix, letter, suffix node', () async {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}a$suffixSymbol');
      var parser = LetterDigitParser();
      var parsedNode = await parser.parse(rootNode);
      expect(parsedNode.children, [
        TextNode(rootNode, prefixSymbol),
        TextNode(rootNode, letterSymbol),
        TextNode(rootNode, suffixSymbol),
      ]);
    });
    test('prefix, digit, letter, digit, suffix', () async {
      var rootNode = RootNodeWithTextNode('${prefixSymbol}1a3$suffixSymbol');
      var parser = LetterDigitParser();
      var parsedNode = await parser.parse(rootNode);
      expect(parsedNode.children, [
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
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) =>
      Future.value(TextNode(parent, letterSymbol));
}

class DigitParserRule extends TextParserRule {
  DigitParserRule() : super(FluentRegex().digit());

  @override
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match) =>
      Future.value(TextNode(parent, digitSymbol));
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
