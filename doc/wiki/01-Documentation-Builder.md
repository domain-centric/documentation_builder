[//]: # (This file was generated from: doc/template/doc/wiki/01-Documentation-Builder.md.template using the documentation_builder package)
![](https://github.com/domain-centric/documentation_builder/wiki/documentation_builder.jpeg)

Generates documentation files from template files.
This can be useful when you write documentation for a
[Dart](https://dart.dev/) or [Flutter](https://flutter.dev/) project
and want to reuse/import files or Dart documentation comments.

It can generate any type of text file e.g.:
* [README.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#readmemd)
* [LICENSE](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#license)
* [CHANGELOG.md](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#changelogmd)
* [Example files](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#examplemd)
* [GitHub wiki files](https://github.com/domain-centric/documentation_builder/wiki/10-Examples#pages)
* or any other text file

[documentation_builder](https://pub.dev/packages/documentation_builder) is not intended to generate API documentation.
Use [dartdoc](https://dart.dev/tools/dartdoc) instead.

# Features
[documentation_builder](https://pub.dev/packages/documentation_builder) uses the [template_engine](https://pub.dev/packages/template_engine) package with additional functions for documentation.
The most commonly used functions for documentation are:
* [Import Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#import-functions)
* [Generator Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#generator-functions)
* [Path Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#path-functions)
* [Link Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#link-functions)
* [Badge Functions](https://github.com/domain-centric/documentation_builder/wiki/06-Functions#badge-functions)

# Breaking Changes
[documentation_builder](https://pub.dev/packages/documentation_builder) 1.0.0 has had major improvements over earlier versions:
* It uses the [DocumentationTemplateEngine](https://github.com/domain-centric/documentation_builder/blob/5d487869dc0170e1a402fbd93af06eabf66500a4/lib/src/builder/documentation_builder.dart#L42) which is an extended version of the [TemplateEngine](https://github.com/domain-centric/documentation_builder/blob/5d487869dc0170e1a402fbd93af06eabf66500a4/lib/src/builder/documentation_builder.dart#L42) from the [template_engine](https://pub.dev/packages/template_engine) package
  * Less error prone: The builder will keep running even if one of the templates fails to parse or render.
  * Better error messages with the position within a template file.
  * Expressions in template file tags can be nested
  * More features: The [DocumentationTemplateEngine](https://github.com/domain-centric/documentation_builder/blob/5d487869dc0170e1a402fbd93af06eabf66500a4/lib/src/builder/documentation_builder.dart#L42) can be extended with custom:
    * dataTypes
    * constants
    * functionGroups
    * operatorGroups
  * More consistent template syntax: now all functions
* The [input and output file is determined by parameters in the build.yaml file](https://github.com/domain-centric/documentation_builder/wiki/02-Getting-Started#build-option-parameter-inputpath), which is:
  * Easier to understand than the old DocumentationBuilder conventions
  * More flexible: It can now be configured in the build.yaml file
* Each generated file can have an optional [header text which can be configured in the build.yaml per output file suffix](https://github.com/domain-centric/documentation_builder/wiki/02-Getting-Started#build-option-parameter-fileheaders).

This resulted in the following breaking changes:
* Tags
  | old syntax                                                                      | new syntax |
  |---------------------------------------------------------------------------------|------------|
  | {ImportFile file:'OtherTemplateFile.md.template' title='# Other Template File'} | # Other Template File<br>{{importTemplate('OtherTemplateFile.md.template')}} |
  | {ImportCode file:'file_to_import.txt' title='# Code example'}                   | # Code example<br>{{importCode('file_to_import.txt')}} |
  | {ImportDartCode file:'file_to_import.dart' title='# Dart code example'}         | # Dart code example<br>{{importDartCode('file_to_import.dart')}} |
  | {ImportDartDoc path='lib\my_lib.dart&#124;MyClass' title='# My Class'}          | # My Class<br>{{importDartDoc('lib\my_lib.dart&#124;MyClass')}} |
  | {TableOfContents title='# Table of contents example'}                           | # Table of contents<br>{{tableOfContents(path='doc/template/doc/wiki')}} |
  | {MitLicense name='John Doe'}                                                    | {{license(type='MIT', name='John Doe')}} |

  See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#import-functions) for more details on these and new functions
* Links
  | old syntax               | new syntax |
  |--------------------------|------------|
  | &#91;GitHub]             | {{gitHubLink()}} |
  | &#91;GitHubWiki]         | {{gitHubWikiLink()}} |
  | &#91;GitHubStars]        | {{gitHubStarsLink()}} |
  | &#91;GitHubIssues]       | {{gitHubIssuesLink()}} |
  | &#91;GitHubMilestones]   | {{gitHubMilestonesLink()}} |
  | &#91;GitHubReleases]     | {{gitHubReleasesLink()}} |
  | &#91;GitHubPullRequests] | {{gitHubPullRequestsLink()}} |
  | &#91;GitHubRaw]          | {{referenceLink('ref')}} or{{gitHubRawLink()}} |
  | &#91;PubDev]             | {{pubDevLink()}} |
  | &#91;PubDevChangeLog]    | {{pubDevChangeLogLink()}} |
  | &#91;PubDevVersions]     | {{pubDevVersionsLink()}} |
  | &#91;PubDevExample]      | {{pubDevExampleLink()}} |
  | &#91;PubDevInstall]      | {{pubDevInstallLink()}} |
  | &#91;PubDevScore]        | {{pubDevScoreLink()}} |
  | &#91;PubDevLicense]      | {{pubDevLicenseLink()}} |
  | PubDev package links     | {{referenceLink()}} |
  | Dart code links          | {{referenceLink('ref')}} |
  | Markdown file links      | &#91;title](URI) |

  See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#link-functions) for more details on these and new functions
* Badges
  | old syntax                                  | new syntax                    |
  |---------------------------------------------|-------------------------------|
  | &#91;CustomBadge title='title' ...]         | &#91;title]({{customBadge()}})             |
  | &#91;PubPackageBadge title='title']         | &#91;title]({{pubPackageBadge()}})         |
  | &#91;GitHubBadge title='title']             | &#91;title]({{gitHubBadge()}})             |
  | &#91;GitHubWikiBadge title='title']         | &#91;title]({{gitHubWikiBadge()}})         |
  | &#91;GitHubStarsBadge title='title']        | &#91;title]({{gitHubStarsBadge()}})        |
  | &#91;GitHubIssuesBadge title='title']       | &#91;title]({{gitHubIssuesBadge()}})       |
  | &#91;GitHubPullRequestsBadge title='title'] | &#91;title]({{gitHubPullRequestsBadge()}}) |
  | &#91;GitHubLicenseBadge title='title']      | &#91;title]({{gitHubLicenseBadge()}})      |

  See the [function documentation](https://github.com/domain-centric/documentation_builder/wiki/06-Functions.md#badge-functions) for more details on these and new functions
* Github-Wiki pages are now generated somewhere in the project folder (e.g. doc\wiki) and need to be copied to GitHub.
  This could be done using GitHub actions (e.g. after each commit).
  For more information see [Automatically Publishing Wiki pages](https://github.com/domain-centric/documentation_builder/wiki/09-Publishing#automatically-publishing-wiki-pages)