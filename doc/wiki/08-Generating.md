[//]: # (This file was generated from: doc/template/doc/wiki/08-Generating.md.template using the documentation_builder package)

The [documentation_builder](https://pub.dev/packages/documentation_builder) is a builder that is run with the [build_runner](https://pub.dev/packages/build_runner) package.

The [build_runner](https://pub.dev/packages/build_runner) can be started from the command line in the root of the project:
* ALT+F12 if you are using [Android Studio](https://developer.android.com/studio) or [Intellij](https://www.jetbrains.com/idea/))
* CTRL/CMD+ALT+t if you are using [Visual Studio Code](https://code.visualstudio.com/)

To run once:
```dart run build_runner build --delete-conflicting-outputs```

To automatically run when files are updated:
```dart run build_runner watch --delete-conflicting-outputs```

Add the `--verbose` attribute if you want to see more details.

[build_runner](https://pub.dev/packages/build_runner) is very efficient. It will only rebuild files that have changed. Sometimes some template files might need to be rebuild, but [build_runner](https://pub.dev/packages/build_runner) cannot evaluate the expression tags, so has no way of knowing this.
You can tell [build_runner](https://pub.dev/packages/build_runner) to clean its history with the follow command:
```dart run build_runner clean```
You can than rebuild everything with build or watch commands.

Note that if you remove or rename a template file, you also need to remove the old generated file.