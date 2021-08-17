import 'dart:async';

import 'package:build/build.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/builders/tags.dart';
import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/generic/markdown_model.dart';

/// replaces all [Tag]s in the [DocumentationModel.markdownPages].
class TagBuilder implements Builder {
  /// '$lib$' makes the build_runner run [TagBuilder] only one time (not for each individual file)
  /// This builder stores the result in the [DocumentationModel] resource to be further processed by other Builders.
  /// the buildExtension outputs therefore do not matter ('dummy.dummy') .
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['dummy.dummy']
      };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    DocumentationModel model =
        await buildStep.fetchResource<DocumentationModel>(resource);
    replaceAllTagsInModel(model);
  }

  void replaceAllTagsInModel(DocumentationModel model) {
    model.markdownPages.forEach((markdownPage) {
      replaceAllTagsInMarkdownModel(markdownPage);
    });
  }

  void replaceAllTagsInMarkdownModel(MarkdownPage markdownPage) {
    TagMatchResult? result;
    do {
      result = findTagMatchInMarkdownParent(markdownPage);
      if (result != null) {
        result.replaceMarkdownTextNode();
      }
    } while (result != null);
  }

  TagMatchResult? findTagMatchInMarkdownParent(MarkdownParent markdownParent) {
    for (MarkdownNode markdownNode in markdownParent.markdownNodes) {
      if (markdownNode is MarkdownText) {
        var result=findTagMatchInMarkdownText(markdownParent, markdownNode);
        if (result!=null) {
          return result;
        }
      } else if (markdownNode is MarkdownParent) {
        //recursive call for nodes that have children
        var result= findTagMatchInMarkdownParent(markdownNode);
        if (result!=null) {
          return result;
        }
      }
    }
    //tested all nodes but no match
    return null;
  }

  findTagMatchInMarkdownText(MarkdownParent markdownParent, MarkdownText markdownNode) {
    for (TagFactory tagFactory in TagFactories()) {
      var firstMatch = tagFactory.fluentRegex.firstMatch(markdownNode.text);
      if (firstMatch != null) {
        return TagMatchResult(
          markdownParent: markdownParent,
          markdownText: markdownNode,
          tagFactory: tagFactory,
          start: firstMatch.start,
          end: firstMatch.end,
        );
      }
    }
    return null;
  }
}

class TagMatchResult {
  final MarkdownParent markdownParent;
  final MarkdownText markdownText;
  final List<MarkdownNode> replacementNodes;

  TagMatchResult({
    required this.markdownParent,
    required this.markdownText,
    required TagFactory tagFactory,
    required int start,
    required int end,
  }) : replacementNodes = createReplacementNodes(
            text: markdownText.text,
            tagFactory: tagFactory,
            start: start,
            end: end);

  static createReplacementNodes(
      {required String text,
      required TagFactory<Tag> tagFactory,
      required int start,
      required int end}) {
    List<MarkdownNode> replacementNodes = [];

    String textBefore = text.substring(0, start);
    if (textBefore.isNotEmpty) {
      replacementNodes.add(MarkdownText(textBefore));
    }

    String tagText = text.substring(start, end);
    var tagReplacements = tagFactory.createFromString(tagText);
    replacementNodes.add(tagReplacements);

    String textAfter = text.substring(end);
    if (textAfter.isNotEmpty) {
      replacementNodes.add(MarkdownText(textAfter));
    }
    return replacementNodes;
  }

  void replaceMarkdownTextNode() {
    int index = markdownParent.markdownNodes.indexOf(markdownText);
    markdownParent.markdownNodes.removeAt(index);
    markdownParent.markdownNodes.insertAll(index, replacementNodes);
  }
}
