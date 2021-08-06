# documentation_builder

Generates documentation from markdown template files.
It is useful when you write documentation for a dart or flutter project and want to reuse/import dart code or dart documentation comments.
It is not intended to generate API documentation. Use [dartdoc](https://dart.dev/tools/dartdoc) instead.

Depending on BuildRunner parameters it generates:
- README.md and/or CHANGELOG.md files
- Github Wiki pages (also markdown files)

Using Mark down template files (files with .mdt extension):
- See https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#links
- can import from other files e.g. {importFile otherTextFile.txt <as Title>} or {importFile otherMarkDownFile.md <as Title>}
- can import dart documentation comments from dart files e.g. {importDoc my_dart_file.dart.MyClass<.MyMember> <as Title>}
- can import dart code from dart files e.g. {importCode my_dart_file.dart.MyClass<.MyMember> <as Title>}
- can resolve internal links like [MyClass<.MyMember>] to imports such as above (if they exist)
- can generate a table of contents e.g. {tableOfContents <mdt files to ignore>}
- can generate a change log e.g. {change log <git details>}


The first line of the generated file will contain some kind of comment stating that the file was generated (with source file, date and time)

## Getting Started
