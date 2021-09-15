[//]: # (This file was generated from: doc/template/02-Markdown-Template-Files.mdt using the documentation_builder package on: 2021-09-15 20:45:16.050740.)
<a id='lib-builder-template-builder-dart-markdowntemplatefile'></a>[MarkdownTemplateFile](https://github.com/efficientyboosters/documentation_builder/wiki/02-Markdown-Template-Files#lib-builder-template-builder-dart-markdowntemplatefile)s are files with a .mdt extension that can contain:
- [Markdown](https://www.markdownguide.org/cheat-sheet/) text
- [Tag](https://github.com/efficientyboosters/documentation_builder/wiki/03-Tags#lib-parser-tag-parser-dart-tag)s
- [Link](https://github.com/efficientyboosters/documentation_builder/wiki/04-Links#lib-parser-link-parser-dart-link)s
- [Badge]s

[MarkdownTemplateFile](https://github.com/efficientyboosters/documentation_builder/wiki/02-Markdown-Template-Files#lib-builder-template-builder-dart-markdowntemplatefile)s are converted to [GeneratedMarkdownFile](https://github.com/efficientyboosters/documentation_builder/wiki/02-Markdown-Template-Files#lib-builder-template-builder-dart-generatedmarkdownfile)s


<a id='lib-builder-template-builder-dart-generatedmarkdownfile'></a>[GeneratedMarkdownFile](https://github.com/efficientyboosters/documentation_builder/wiki/02-Markdown-Template-Files#lib-builder-template-builder-dart-generatedmarkdownfile)s are files with a .md extension that are generated
by the [DocumentationBuilder](https://github.com/efficientyboosters/documentation_builder/wiki/01-Documentation-Builder#lib-builder-documentation-builder-dart-documentationbuilder).


<a id='readme-template-file'></a>
### README template file
A README.md file is tippacally the first item a visitor will see when visiting
your package on https://pub.dev or visiting your code on https://github.com.

A README.md file typically include information on:
- What the project does
- Why the project is useful
- How to use it
- other relevant high level information

A README.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder](https://github.com/efficientyboosters/documentation_builder/wiki/01-Documentation-Builder#lib-builder-documentation-builder-dart-documentationbuilder)
to create or override the README.md file in the root of your dart project.


<a id='changelog-template-file'></a>
### CHANGELOG template file
A CHANGELOG.md is a log or record of all notable changes made to a project.
To support tools that parse CHANGELOG.md, use the following format:
- Each version has its own section with a heading.
- The version headings are either a chapter (#) or a paragraph (##).
- The version heading text contains a package version number, optionally prefixed with “v”.

A CHANGELOG.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder](https://github.com/efficientyboosters/documentation_builder/wiki/01-Documentation-Builder#lib-builder-documentation-builder-dart-documentationbuilder)
to create or override the CHANGELOG.md file in the root of your dart project.

A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG] which will generate the
versions assuming you are using GitHub and mark very version as a milestone


<a id='wiki-template-files'></a>
### Wiki template files
Project's that are stored in [Github](https://github.com/) can have wiki pages.
[Github](https://github.com/) wiki pages are markdown files.
See [Github Wiki pages](TODO%20Add%20link) for more information.


Any [MarkdownTemplate] is considered to be a [WikiMarkdownTemplateFile] when:
- Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
- Its name starts with 2 digits, and has a .mdt extension (e.g.: 07-Getting-Started.mdt)


<a id='example-template-file'></a>
### example template file
Your Dart/Flutter project can have an example.md file
A example.mdt is a [MarkdownTemplate] that is used by the
[DocumentationBuilder](https://github.com/efficientyboosters/documentation_builder/wiki/01-Documentation-Builder#lib-builder-documentation-builder-dart-documentationbuilder) to create or override the example.md file in the
example folder of your dart project.

