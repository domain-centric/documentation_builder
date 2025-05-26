import 'package:build/build.dart';
import 'package:documentation_builder/src/builder/documentation_builder.dart';

/// Factory function that is referred to by the build.yaml file.
Builder documentationBuilder(BuilderOptions builderOptions) =>
    DocumentationBuilder(builderOptions);
