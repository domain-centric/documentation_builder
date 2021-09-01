[//]: # (This file was generated from: doc/templates/README.mdt using the documentation_builder package on: 2021-09-01 12:34:08.367851.)
[![Pub Package](https://img.shields.io/pub/v/fluent_regex)](https://pub.dev/packages/fluent_regex)
[![Code Repository](https://img.shields.io/badge/repository-git%20hub-blue)](https://github.com/efficientyboosters/documentation_builder)
[![Github Wiki](https://img.shields.io/badge/documentation-wiki-blue)](https://github.com/efficientyboosters/documentation_builder/wiki)
[![GitHub Stars](https://img.shields.io/github/stars/efficientyboosters/documentation_builder)](https://github.com/efficientyboosters/documentation_builder/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/efficientyboosters/documentation_builder/blob/main/LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/efficientyboosters/documentation_builder)](https://github.com/efficientyboosters/documentation_builder/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/efficientyboosters/documentation_builder)](https://github.com/efficientyboosters/documentation_builder/pull)

<a id='documentation-builder'></a>
# documentation_builder
Generates markdown documentation files from markdown template files.
This can be useful when you write documentation for a Dart or Flutter project and want to reuse/import Dart code or Dart documentation comments.
[documentation_builder] is not intended to generate API documentation. Use [dartdoc](https://dart.dev/tools/dartdoc) instead.

TODO: use [MarkdownTemplateFileFactories]
It can generate the following files:
- README.md file
- CHANGELOG.mdt file
- example.md file
- Github Wiki pages (also markdown files)


<a id='examples'></a>
## Examples
The [DocumentationBuilder]s own documentation was generated by itself and also serves as show case.

You can view the templates files and the generated output on https://github.com and https://pub.dev:

- README
  - [GitHubProject path='/glob/main/doc/templates/README.mdt' title='Markdown Template File']
  - [GitHubProject path='/glob/README.md' title='Generated Markdown File']
  - [PubDevProject title='Generated Markdown Page']
- CHANGELOG
  - [GitHubProject path='/glob/main/doc/templates/CHANGELOG.mdt' title='Markdown Template File']
  - [GitHubProject path='/glob/main/CHANGELOG.md' title='Generated Markdown File']
  - [PubDevProjectVersions title='Generated Markdown Page']
- Wiki pages
  - [GitHubProject path='/glob/main/doc/templates' title='Markdown Template Files']
  - [GitHubProject path='/glob/main/doc/wiki title='Generated Markdown Files']
  - [GitHubProjectWiki title='Generated Markdown Pages']
- example
  - [GitHubProject path='/glob/main/doc/templates/example.mdt' title='Markdown Template File']
  - [GitHubProject path='/glob/main/example/example.md' title='Generated Markdown File']
  - [GitHubProjectExample title='Generated Markdown Page']

<a id='getting-started'></a>
## Getting Started
- Read the [GitHubProjectWiki title='Wiki documentation']
- [PubDevInstall title='Install the documentation_builder package'] in your project
- Create 'doc/templates' directories in the root of your project
- [02-Markdown-Template-Files.mdt title='Create markdown template files'] in the "doc/templates" directory ([06-Examples.mdt title='see examples'])
- [05-Generating-Documentation-Files.mdt title='Generate the documentation files']