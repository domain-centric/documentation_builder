import 'package:build/build.dart';
import 'package:documentation_builder/builder/documentation_builder.dart';
import 'package:documentation_builder/builder/output_builder.dart';
import 'package:documentation_builder/builder/parse_builder.dart';
import 'package:documentation_builder/builder/template_builder.dart';

/// The [DocumentationBuilder] process is executed by several builder.
/// These are configured in the build.yaml file, which refers to this library to create these builder.
///
/// In order of execution:
/// - [MarkdownTemplateBuilder]
/// - [ParseBuilder]
/// - [OutputBuilder]

Builder markdownTemplateBuilder(BuilderOptions builderOptions) =>
    MarkdownTemplateBuilder();

Builder parseBuilder(BuilderOptions builderOptions) =>
    ParseBuilder();

Builder outputBuilder(BuilderOptions builderOptions) =>
    OutputBuilder();
