import 'package:documentation_builder/markdown_template_files.dart';

import 'builders.dart';

/// [MarkdownTemplateFile]s can contain [Tag]s that are replaced by the [DocumentationBuilder].
///
/// [Tag]s:
/// - are surrounded by curly brackets: {}
/// - have a name: e.g.  {ImportFile}
/// - may have attributes: e.g. {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
abstract class Tag extends MarkDownText {}

/// [ImportFileTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'}
/// - It imports another file.
/// - Attributes:
///   - file: (mandatory) a file name inside the markdown\ directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportFileTag extends Tag {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

/// [ImportCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportCodeTag file:'file_to_import.txt' title:'## Code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - file: (mandatory) a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag] to import Dart code
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportCodeTag extends Tag {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

/// [ImportDartCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartCodeTag file:'file_to_import.dart' title:'## Dart code example'}
/// - It imports a (none Dart) code file.
/// - Attributes:
///   - file: (mandatory) a file path that needs to be imported as a Dart code example. See also [ImportCodeTag] to import none Dart code.
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartCodeTag extends Tag {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

/// [ImportDartDocTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartDoc member:'lib\my_lib.dart.MyClass' title:'## My Class'}
/// - It imports dart documentation comments from dart files.
/// - Attributes:
///   - member: (mandatory) a dart file name, followed by one of the following:
///     - .constantName
///     - .functionName
///     - .EnumName (optionally followed by a dot and a enum value)
///     - .ClassName (optionally followed by a dot and a class member such as a field name or method name)
///     - .ExtensionName  (optionally followed by a dot and a extension member such as a field name or method name)
///   - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]
class ImportDartDocTag extends Tag {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

/// TODO - generate a table of contents e.g. {tableOfContents <x levels deep>}}
/// TODO - generate a change log e.g. {ChangeLog <git details>}
