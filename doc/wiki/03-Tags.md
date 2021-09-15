[//]: # (This file was generated from: doc/template/03-Tags.mdt using the documentation_builder package on: 2021-09-15 20:45:16.042763.)
<a id='lib-parser-tag-parser-dart-tag'></a>[Tag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#lib-parser-tag-parser-dart-tag)s are specific texts in [MarkdownTemplate]s that are replaced by the
 [DocumentationBuilder](https://github.com/efficientyboosters/documentation_builder/wiki/01-Documentation-Builder#lib-builder-documentation-builder-dart-documentationbuilder) with other information
 (e.g. by an imported Dart Documentation Comment) before the
 [GeneratedMarkdownFile](https://github.com/efficientyboosters/documentation_builder/wiki/02-Markdown-Template-Files#lib-builder-template-builder-dart-generatedmarkdownfile) is written.

[Tag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#lib-parser-tag-parser-dart-tag)s:
- are surrounded by curly brackets: {}
- start with a name: e.g.  {ImportFile&rcub;
- may have [Attribute](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#tag-attributes)s after the name:
  e.g. {ImportFile path='OtherTemplateFile.mdt' title='## Other Template File'&rcub;


<a id='tag-attributes'></a>
## Tag Attributes
[Tag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#lib-parser-tag-parser-dart-tag)s can contain [Attribute](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#tag-attributes)s. These contain additional information for the [Tag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#lib-parser-tag-parser-dart-tag).
[Attribute](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#tag-attributes)s can be mandatory or optional.

The following paragraphs will explain the format of different path [Attribute](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#tag-attributes)s:

<a id='project-file-path'></a>
### Project File Path
[ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) is a reference to a file in your source project
- The [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) is always relative to root directory of the project directory.
- The [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) will always be within the project directory, that is they will never contain "../".
- The [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) always uses forward slashes as path separators, regardless of the host platform (also for Windows).

Example: doc/wiki/Home.md


<a id='dart-code-path'></a>
### Dart Code Path
A [DartCodePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-code-path) is a reference to a piece of your Dart source code.
This could be anything from a whole dart file to one of its members.
Format: <[DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path)>|<[DartMemberPath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-member-path)>
- <[DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path)> (required) is a [DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path) to a Dart file without dart extension, e.g. lib/my_library.dart
- |: the <[DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path)> and <[DartMemberPath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-member-path)> are separated with a vertical bar | when there is a [DartMemberPath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-member-path).
- <[DartMemberPath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-member-path)> (optional) is a dot separated path to the member inside the Dart file, e.g.
  - .constantName
  - .functionName
  - .EnumName (optionally followed by a dot and a enum value)
  - .ClassName (optionally followed by a dot and a class member such as a field name or method name)
  - .ExtensionName  (optionally followed by a dot and a extension member such as a field name or method name)

Examples:
- lib/my_library.dart
- lib/my_library.dart|myConstant
- lib/my_library.dart|myFunction
- lib/my_library.dart|MyEnum
- lib/my_library.dart|MyEnum.myValue
- lib/my_library.dart|MyClass
- lib/my_library.dart|MyClass.myFieldName
- lib/my_library.dart|MyClass.myFieldName.get
- lib/my_library.dart|MyClass.myFieldName.set
- lib/my_library.dart|MyClass.myMethod
- lib/my_library.dart|MyExtension
- lib/my_library.dart|MyExtension.myFieldName
- lib/my_library.dart|MyExtension.myFieldName.get
- lib/my_library.dart|MyExtension.myFieldName.set
- lib/my_library.dart|MyExtension.myMethod


<a id='dart-file-path'></a>
### Dart File Path
A [DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path) is a [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) to a dart file.
It must end with a '.dart' extension.

Example: lib/my_library.dart


<a id='dart-member-path'></a>
### Dart Member Path
A [DartMemberPath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-member-path) is a dot separated path to a member inside the Dart file.
It is a part of a [DartCodePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-code-path).

Examples:
- myConstant
- myFunction
- MyEnum
- MyEnum.myValue
- MyClass
- MyClass.myFieldName
- MyClass.myFieldName.get
- MyClass.myFieldName.set
- MyClass.myMethod
- MyExtension
- MyExtension.myFieldName
- MyExtension.myFieldName.get
- MyExtension.myFieldName.set
- MyExtension.myMethod


## Tag types
The following paragraphs will explain the different tags:

<a id='import-file-tag'></a>
### Import File Tag
- **{ImportFile file:'OtherTemplateFile.mdt' title='## Other Template File'&rcub;**
- Imports another text file or markdown file.
- Attributes:
  - path= (required) A [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) to a file name inside the markdown
    directory that needs to be imported. This may be any type of text file (e.g. .mdt file).
  - title= (optional) title. You can precede the title with a number of #
    to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph).
    A title can be referenced in the documentation with a [Link](https://github.com/efficientyboosters/documentation_builder/wiki/04-Links#lib-parser-link-parser-dart-link)


<a id='import-code-tag'></a>
### Import Code Tag
- **{ImportCodeTag file:'file_to_import.txt' title='## Code example'&rcub;**
- Imports a (none Dart) code file.
- Attributes:
  - path= (required) A [ProjectFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#project-file-path) a file path that needs to be imported as a (none Dart) code example. See also [ImportDartCodeTag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#import-dart-code-tag) to import Dart code
  - title= (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link](https://github.com/efficientyboosters/documentation_builder/wiki/04-Links#lib-parser-link-parser-dart-link)


<a id='import-dart-code-tag'></a>
### Import Dart Code Tag
- **{ImportDartCodeTag file:'file_to_import.dart' title='## Dart code example'&rcub;**
- Imports a (none Dart) code file.
- Attributes:
  - path= (required) A [DartFilePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-file-path) to be imported as a Dart code example. See also [ImportCodeTag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#import-code-tag) to import none Dart code.
  - title= (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link](https://github.com/efficientyboosters/documentation_builder/wiki/04-Links#lib-parser-link-parser-dart-link)


<a id='import-dart-documentation-comments-tag'></a>
### Import Dart Documentation Comments Tag
- **{ImportDartDoc path='lib\my_lib.dart|MyClass' title='## My Class'&rcub;**
- Imports Dart documentation comments from a library member in a dart file.
- Attributes:
  - path= (required) A [DartCodePath](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#dart-code-path) to be imported Dart comments.
  - title= (optional) title. You can precede the title with a number of # to indicate the title level (#=chapter, ##=paragraph, ###=sub paragraph). A title can be referenced in the documentation with a [Link](https://github.com/efficientyboosters/documentation_builder/wiki/04-Links#lib-parser-link-parser-dart-link)

