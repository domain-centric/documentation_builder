import 'package:build/build.dart';
import 'package:documentation_builder/builders/markdown_template_files.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/local_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';

/// All information needed to generate the markdown documentation files.
class DocumentationModel {
  final LocalProject localProject = LocalProject();
  final GitHubProject gitHubProject = GitHubProject();
  final PubDevProject pubDevProject = PubDevProject();
  final List<MarkdownTemplateFile> markdownTemplateFiles = [];
}

/// A [Resource] containing the [DocumentationModel] so that it can be shared between builders.
final resource = Resource(() => DocumentationModel());
