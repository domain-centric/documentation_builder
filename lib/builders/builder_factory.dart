import 'package:build/build.dart';
import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/builders/markdown_template_builder.dart';

/// The [build_runner] package will call its configured builder classes (see build.yaml) for each file it finds.
///
/// The [build_runner] is started with the following command in the root of the project:
/// $ flutter packages pub run build_runner build --delete-conflicting-outputs
///
/// You’d better clean up before you re-execute run builder_runner
/// $ flutter packages pub run build_runner clean

Builder markdownTemplateBuilder(BuilderOptions builderOptions) =>
    MarkdownTemplateBuilder();

Builder documentationBuilder(BuilderOptions builderOptions) =>
    DocumentationBuilder();
