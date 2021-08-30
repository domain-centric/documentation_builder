[//]: # (This file was generated from: doc/templates/05-Generating-Documentation-Files.mdt using the documentation_builder package on: 2021-08-30 14:54:07.276026.)


These commands are cumbersome.

You can therefore also create a tools folder in the root of your project and add the following 'generate_markdown_files.dart' file in this folder.
You can now run these commands by running the 'generate_markdown_files.dart' file from your favourite IDE.

<a id='tools-generate-markdown-files-dart'></a>
```dart
import 'package:documentation_builder/builders/documentation_builder.dart';main() {
  DocumentationBuilder().run();
}
```
