[//]: # (This file was generated from: doc/templates/02-Markdown-Template-Files.mdt using the documentation_builder package on: 2021-09-01 20:05:06.050171.)
<a id='lib-builders-template-builder-dart-markdowntemplatefile'></a>[MarkdownTemplateFile]s are files with a .mdt extension that can contain:
- [Markdown](https://www.markdownguide.org/cheat-sheet/) text
- [Tag]s
- [Link]s
- [Badge]s
[MarkdownTemplateFile]s are converted to [GeneratedMarkdownFile]s


<a id='lib-builders-template-builder-dart-generatedmarkdownfile'></a>[GeneratedMarkdownFile]s are files with a .md extension that are generated
by the [DocumentationBuilder].


<a id='readme-template-file'></a>
### README template file
README.md files are .....TODO explain what a README file is and what it should contain.
A README.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder] to create or override the README.md file in the root of your dart project.


<a id='changelog-template-file'></a>
### CHANGELOG template file
CHANGELOG.mdt files are .....TODO explain what a CHANGELOG file is and what it should contain.
A CHANGELOG.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder] to create or override the CHANGELOG.md file in the root of your dart project.
A CHANGELOG.mdt can use the [TODO CHANGELOG_TAG]
which will generate the versions assuming you are using GitHub and mark very version as a milestone


<a id='wiki-template-files'></a>
### Wiki template files
Project's that are stored in [Github](https://github.com/) can have wiki pages.
[Github](https://github.com/) wiki pages are markdown files.
See [Github Wiki pages](TODO Add link) for more information.


Any [MarkdownTemplate] is considered to be a [WikiMarkdownTemplateFile] when:
- Its name is: Home.mdt This is the wiki landing page which often contains a [TableOfContentTag]
- Its name starts with 2 digits, and has a .mdt extension (e.g.: 07-Getting-Started.mdt)


<a id='example-template-file'></a>
### example template file
Your Dart/Flutter project can have an example.md file
A example.mdt is a [MarkdownTemplate] that is used by the [DocumentationBuilder] to create or override the example.md file in the example folder of your dart project.

