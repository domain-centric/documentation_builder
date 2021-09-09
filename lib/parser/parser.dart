import 'package:collection/collection.dart';
import 'package:documentation_builder/builder/template_builder.dart';
import 'package:fluent_regex/fluent_regex.dart';

/// A [Parser] checks if any of its rules can replace nodes in the model.
abstract class Parser {
  final List<ParserRule> rules;

  Parser(this.rules);

  /// replaces all child [Node]s in the [RootNode] according to the [rules]
  /// Note that this starts all over at the first rule when nodes where found and replaced.
  /// Throws a ParseWarning when there where warnings
  Future<RootNode> parse(RootNode rootNode) async {
    List<ParserWarning> warnings = [];
    rootNode.resetLastCompletedRuleIndexes();
    rootNode = await _findAndReplaceNodes(rootNode, warnings);
    if (warnings.isNotEmpty) throw new ParserWarning(warnings.join('\n'));
    return rootNode;
  }

  Future<RootNode> _findAndReplaceNodes(
      RootNode rootNode, List<ParserWarning> warnings) async {
    if (rules.isEmpty) return rootNode;
    ParserRule rule = rules.first;
    bool done = false;
    do {
      try {
        ParentNode? uncompletedNode =
            rootNode.findNodeWithUncompletedRule(rules.indexOf(rule));
        if (uncompletedNode == null) {
          if (rule == rules.last) {
            done = true;
          } else {
            rule = _nextRule(rule);
          }
        } else {
          var childrenNodesToReplace =
              await rule.findChildNodesToReplace(uncompletedNode);
          if (childrenNodesToReplace.isEmpty) {
            _markRuleAsCompletedForNode(rule, uncompletedNode);
          } else {
            try {
              await _replaceChildNodes(rule, childrenNodesToReplace);
              // check new nodes (re)starting with the first rule
              rule = rules.first;
            } on ParserWarning catch (warning) {
              // Failed to create replacement nodes.
              // Mark rule as completed to prevent an endless loop
              _markRuleAsCompletedForNode(rule, uncompletedNode);
              logWarning(warnings, uncompletedNode, warning);
            }
          }
        }
      } on ParserWarning catch (warning) {
        warnings.add(warning);
      }
    } while (!done);
    return rootNode;
  }

  ParserRule _nextRule(ParserRule rule) => rules[rules.indexOf(rule) + 1];

  Future<void> _replaceChildNodes(
    ParserRule rule,
    ChildNodesToReplace childNodesToReplace,
  ) async {
    Node firstChild = childNodesToReplace.first;
    ParentNode parent = firstChild.parent!;
    int startIndex = parent.children.indexOf(firstChild);
    if (startIndex == -1) {
      throw new ParserError(
          'First child to replace not found from rule: $rule');
      //It is likely that one or more children have an invalid parent (use this as parent in parser rules!)
    }
    List<Node> replacementNodes =
        await rule.createReplacementNodes(childNodesToReplace);
    _removeNodesToBeReplaced(startIndex, childNodesToReplace, parent);
    parent.children.insertAll(startIndex, replacementNodes);
  }

  void logWarning(List<ParserWarning> warnings, ParentNode parent,
      ParserWarning newWarning) {
    var markDownPage = parent.findParent<MarkdownTemplate>();
    if (markDownPage == null) {
      warnings.add(newWarning);
    } else {
      warnings.add(ParserWarning(
          'Parse warning for: ${markDownPage.sourceFilePath}', newWarning));
    }
  }

  void _removeNodesToBeReplaced(int startIndex,
      ChildNodesToReplace childNodesToReplace, ParentNode parent) {
    for (int index = startIndex;
        index < startIndex + childNodesToReplace.length;
        index++) parent.children.removeAt(index);
  }

  void _markRuleAsCompletedForNode(
      ParserRule rule, ParentNode parentNodeToProcess) {
    parentNodeToProcess.lastCompletedRuleIndex = rules.indexOf(rule);
  }
}

abstract class ParserRule {
  /// checks the whole [ParentNode] (all it children) if it can replace [Node] (s).
  /// We do not need to check the children's children (do not need a recursive call),
  /// the Parser will do this for us
  Future<ChildNodesToReplace> findChildNodesToReplace(ParentNode model);

  Future<List<Node>> createReplacementNodes(
      ChildNodesToReplace childNodesToReplace);
}

/// Looks for a [TextNode] and then matches [TextNode.text] with a [RegExp].
/// It creates replacement nodes
abstract class TextParserRule extends ParserRule {
  final FluentRegex expression;

  TextParserRule(this.expression);

  @override
  /// Searches all child nodes for [TextNode]s that have a match with the [expression]
  Future<ChildNodesToReplace> findChildNodesToReplace(ParentNode node) async {
    for (Node child in node.children) {
      if (child is TextNode ) {
        List<RegExpMatch> matches = await createMatches(child.text);
        if (matches.isNotEmpty) {
          return ChildNodesToReplace.foundNode(child);
        }
      }
    }
    return ChildNodesToReplace.notFound();
  }

  /// It will replace the [TextNode] with:
  /// - [Node]s that represent the text found by the [RegExp]
  /// - [TextNode]s that represent the remaining text
  Future<List<Node>> createReplacementNodes(
      ChildNodesToReplace childNodesToReplace) async {
    TextNode textNode = childNodesToReplace.first as TextNode;
    var parent = textNode.parent!;
    var test = textNode.text;

    List<RegExpMatch> matches = await createMatches(test);

    List<Node> replacementNodes = [];

    TextNode? leadingTextNode =
        createTextBeforeNode(textNode, matches.first.start);
    if (leadingTextNode != null) replacementNodes.add(leadingTextNode);

    RegExpMatch? previousMatch;
    for (RegExpMatch match in matches) {
      if (previousMatch != null) {
        int betweenStart = previousMatch.end;
        int betweenEnd = match.start;
        if (betweenStart < betweenEnd) {
          var betweenText = test.substring(betweenStart, betweenEnd);
          var betweenNode = TextNode(parent, betweenText);
          replacementNodes.add(betweenNode);
        }
      }
      Node replacementNode = await createReplacementNode(parent, match);
      replacementNodes.add(replacementNode);
      previousMatch = match;
    }

    TextNode? trailingTextNode =
        createTrailingTextNode(textNode, matches.last.end);
    if (trailingTextNode != null) replacementNodes.add(trailingTextNode);

    return replacementNodes;
  }

  TextNode? createTextBeforeNode(TextNode textNode, int start) {
    if (start > 0) {
      ParentNode parent = textNode.parent!;
      String textBefore = textNode.text.substring(0, start);
      return TextNode(parent, textBefore);
    } else {
      return null;
    }
  }

  TextNode? createTrailingTextNode(TextNode textNode, int end) {
    String text = textNode.text;
    if (end < text.length) {
      ParentNode parent = textNode.parent!;
      String textAfter = text.substring(end, text.length);
      return TextNode(parent, textAfter);
    } else {
      return null;
    }
  }

  /// Note that the parentNode parameter should only be used to get information from the tree to create replacement nodes.
  /// The [Parser] will add the created replacement node's to the parent.
  Future<Node> createReplacementNode(ParentNode parent, RegExpMatch match);

  /// Removing RegEx matches that are inside other matches.
  /// These will be replaced later when the replacement nodes are parsed
  List<RegExpMatch> removeMatchesInsideMatches(List<RegExpMatch> matches) {
    //TODO
    return matches;
  }

  /// A method that can be overridden by sibling classes if additional logic is needed
  /// This is the default operation
  Future<List<RegExpMatch>> createMatches(String text) {
    var matches = expression.allMatches(text).toList();
    matches = removeMatchesInsideMatches(matches);
    return Future.value(matches);
  }
}

class ChildNodesToReplace extends DelegatingList<Node> {
  ChildNodesToReplace.foundNode(Node child) : super([child]);

  ChildNodesToReplace.foundConsecutiveNodes(List<Node> consecutiveChildNodes)
      : super(consecutiveChildNodes) {
    validateIfNodesHaveTheSameParent();
    validateIfNodesAreConsecutive();
  }

  ChildNodesToReplace.notFound() : super([]);

  void validateIfNodesHaveTheSameParent() {
    ParentNode? parent;
    forEach((node) {
      if (parent == null) {
        parent = node.parent;
      } else if (node.parent != parent) {
        throw ParserError('All nodes must have the same parent');
      }
    });
  }

  void validateIfNodesAreConsecutive() {
    int? childIndex;
    forEach((node) {
      if (childIndex == null) {
        childIndex = findChildIndex(node);
      } else if (findChildIndex(node) != childIndex) {
        throw ParserError('All nodes must be consecutive');
      }
    });
  }

  ParentNode? get parent => isEmpty ? null : first.parent;

  int findChildIndex(Node node) {
    var parent = node.parent;
    return parent!.children.indexOf(node);
  }
}

class Node {
  final ParentNode? parent;

  Node(this.parent);
}

class TextNode extends Node {
  final String text;

  TextNode(ParentNode? parent, this.text) : super(parent);

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextNode &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

class ParentNode extends Node {
  final List<Node> children = [];

  /// A [ParserRule] is done when its [ParserRule.findChildNodesToReplace] method
  /// can no longer find children to replace.
  /// -1 = no [ParserRule]s are done:
  ///      they still all need to check if they can find children to replace
  ///  0 = the first [ParserRule] is done:
  ///      - it did not find any children to replace
  ///      - the remaining rules (if any) still need to check
  ///        if they can find children to replace
  ///  1 = the first 2 [ParserRule]s are done:
  ///      - they did not find any children to replace
  ///      - the remaining rules (if any) still need to check
  ///        if they can find children to replace
  ///  etc
  int lastCompletedRuleIndex = -1;

  ParentNode(ParentNode? parent) : super(parent);

  @override
  String toString() {
    try {
      return children.join();
    } on Exception {
      return "ERROR"; //TODO remove try catch and replace with only  children.join();
    }
  }

  /// Finds the first parent of a given [Type]
  T? findParent<T>() {
    if (this.runtimeType == T) {
      return this as T;
    } else {
      if (parent != null) {
        //find recursively
        var result = parent!.findParent<T>();
        if (result != null) {
          return result;
        }
      }
    }
    return null; //not found
  }

  /// Find a ParentNode that still needs to check the given rule
  ParentNode? findNodeWithUncompletedRule(int ruleIndex) {
    if (lastCompletedRuleIndex < ruleIndex) {
      return this;
    }
    for (Node child in children) {
      if (child is ParentNode) {
        var found = child.findNodeWithUncompletedRule(ruleIndex);
        if (found != null) return found;
      }
    }
    return null;
  }

  void resetLastCompletedRuleIndexes() {
    lastCompletedRuleIndex = -1;
    for (Node child in children) {
      if (child is ParentNode) child.resetLastCompletedRuleIndexes();
    }
  }
}

/// The RootNode must be a [ParentNode] without a parent
class RootNode extends ParentNode {
  RootNode() : super(null);
}

abstract class ParserThrowable {
  final String message;

  ParserThrowable(this.message);
}

/// Throw [ParserWarning]s when a none fatal error occurred and the [Parser] should continue
/// e.g. when calling the [ParserRule.createReplacementNodes] method and
/// a [ParserWarning] was thrown because there was a syntax error.
/// The [Parser] will catch [ParserWarning]s and store them in [Parser.warnings]
/// A [ParserWarning] can be nested.
class ParserWarning extends ParserThrowable {
  final ParserWarning? subWarning;

  ParserWarning(String message, [this.subWarning]) : super(message);

  @override
  String toString() {
    String string = message;
    if (subWarning != null) {
      subWarning.toString().split('\n').forEach((line) {
        string += '\n  $line';
      });
    }
    return string;
  }
}

/// Throw a [ParserError] when there was a fatal error and the parsing could not be completed.
/// A [ParserError] can be nested.
class ParserError extends ParserThrowable {
  final ParserThrowable? subWarning;

  ParserError(String message, [this.subWarning]) : super(message);

  @override
  String toString() {
    String string = message;
    if (subWarning != null) {
      subWarning.toString().split('\n').forEach((line) {
        string += '\n  $line';
      });
    }
    return string;
  }
}

extension MatchExtension on RegExpMatch {
  String get result => input.substring(start, end);
}
