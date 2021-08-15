/// Contains any piece of information that can be converted to markdown text
///
/// For more information on markdown See https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#links
abstract class MarkdownNode {
  String toMarkDownText();

  @override
  String toString() => toMarkDownText();
}

/// An object containing zero or more [MarkdownNode]s
abstract class MarkdownParent extends MarkdownNode {

  List<MarkdownNode>  markdownNodes=[];

  @override
  String toMarkDownText() => markdownNodes.join();
}

/// MarkdownNode containing a static text
class MarkdownText extends MarkdownNode {
  final String text;

  MarkdownText(this.text);

  @override
  String toMarkDownText() => text;
}
