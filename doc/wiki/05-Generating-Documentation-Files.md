[//]: # (This file was generated from: doc/template/05-Generating-Documentation-Files.mdt using the documentation_builder package on: 2021-09-15 07:44:17.158406.)
<a id='lib-builder-documentation-builder-dart-documentationbuilder-run'></a>The [documentation_builder](https://pub.dev/packages/documentation_builder) uses several builder that are run with the [build_runner](https://pub.dev/packages/build_runner) package.

The [build_runner](https://pub.dev/packages/build_runner) is started with the following command in the root of the project (ALT+F12 if you are using Android Studio or Intelij):
```
flutter packages pub run build_runner build --delete-conflicting-outputs
```

You’d better clean up before you re-execute [builder_runner]:
```
flutter packages pub run build_runner clean
```


These commands are cumbersome.

You can therefore also create a tool folder in the root of your project and add the following 'generate_markdown_files.dart' file in this folder.

<a id='tool-generate-markdown-files-dart'></a>
```dart
import 'package:documentation_builder/builder/documentation_builder.dart';main() {
  DocumentationBuilder().run();
}
```


You can now run these commands by running the 'generate_markdown_files.dart' file from your favourite IDE.