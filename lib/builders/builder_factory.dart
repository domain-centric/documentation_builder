import 'package:build/build.dart';
import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/builders/output_builder.dart';
import 'package:documentation_builder/builders/markdown_template_builder.dart';

/// The [DocumentationBuilder] process is executed by several builders.
/// These are configured in the build.yaml file, which refers to this library to create these builders.
///
/// In order of execution:
/// - [MarkdownTemplateBuilder]
/// - TODO [TagBuilder]
/// - TODO [LinkBuilder]
/// - [OutputBuilder]

Builder markdownTemplateBuilder(BuilderOptions builderOptions) =>
    MarkdownTemplateBuilder();

Builder outputBuilder(BuilderOptions builderOptions) =>
    OutputBuilder();
