[//]: # (This file was generated from: doc/templates/03-Tags.mdt using the documentation_builder package on: 2021-09-01 12:34:08.363862.)
<a id='lib-parser-tag-parser-dart-tag'></a>[Tag] objects use [Tag] [Attribute] values to create it's children e.g. by importing some text. Dart code or Dart comments

[Tag]s in text form:
- are surrounded by curly brackets: {}
- start with a name: e.g.  {ImportFile&rcub;
- may have [Attribute]s after the name: e.g. {ImportFile path:'OtherTemplateFile.mdt' title:'## Other Template File'&rcub;


<a id='import-file-tag'></a>
### Import File Tag
[ImportFileTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportFile file:'OtherTemplateFile.mdt' title:'## Other Template File'&rcub;
- It imports another file.
- Attributes:
  - path: (required) A [ProjectFilePath] to a file name inside the markdown directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
  - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]


<a id='import-code-tag'></a>
### Import Code Tag
[ImportCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportCodeTag file:'file_to_import.txt' title:'## Code example'&rcub;
- It imports a (none Dart) code file.
- Attributes:
  - path: (required) A [ProjectFilePath] a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag] to import Dart code
  - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]


<a id='import-dart-code-tag'></a>
### Import Dart Code Tag
[ImportDartCodeTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartCodeTag file:'file_to_import.dart' title:'## Dart code example'&rcub;
- It imports a (none Dart) code file.
- Attributes:
  - path: (required) A [DartCodePath] to be imported as a Dart code example. See also [ImportCodeTag] to import none Dart code.
  - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]


<a id='import-dart-documentation-comments-tag'></a>
### Import Dart Documentation Comments Tag
[ImportDartDocTag]'s have the following format inside a [MarkdownTemplateFile]: {ImportDartDoc member:'lib\my_lib.dart.MyClass' title:'## My Class'&rcub;
- It imports dart documentation comments from dart files.
- Attributes:
  - path: (required) A [DartCodePath] to be imported Dart comments.
  - title: (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link]

