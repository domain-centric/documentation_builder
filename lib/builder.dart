library documentation_builder.builder;

import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/dart_code_path_builder.dart';
import 'package:documentation_builder/src/builder/documentation_builder.dart';
import 'package:documentation_builder/src/builder/output_builder.dart';
import 'package:documentation_builder/src/builder/parse_builder.dart';
import 'package:documentation_builder/src/builder/documentation_model_builder.dart';

/// The [DocumentationBuilder] process is executed by several builder.
/// These are configured in the build.yaml file, which refers to this library to create these builders.
///
/// In order of execution:
/// - [DocumentationModelBuilder]
/// - [ParseBuilder]
/// - [OutputBuilder]

Builder documentationModelBuilder(BuilderOptions builderOptions) =>
    DocumentationModelBuilder();

Builder dartCodePathBuilder(BuilderOptions builderOptions) =>
    DartCodePathBuilder();

Builder parseBuilder(BuilderOptions builderOptions) => ParseBuilder();

Builder outputBuilder(BuilderOptions builderOptions) => OutputBuilder();
