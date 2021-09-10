[//]: # (This file was generated from: doc/template/04-Links.mdt using the documentation_builder package on: 2021-09-10 19:47:13.944944.)
<a id='lib-parser-link-parser-dart-link'></a>You can refer to other parts of the documentation using [Link]s.
[Link]s:
- are references between square brackets [] in [MarkdownTemplateFile]s, e.g.: [MyClass&rsqb;
- can have optional or required attributes, e.g.: [MyClass title='Link to my class'&rsqb;

The [DocumentationBuilder] will try to convert these to hyperlinks that point to an existing http uri.
The [Link] will not be replaced to a hyperlink when the uri does not exits.


<a id='hyperlink'></a>
## Hyperlink
A complete Hyperlink in Markdown is a text between square brackets []
followed by a [Uri] between parentheses (),
e.g.: [Search the webt&rsqb;(https://google.com)

h
<a id='github-project-links'></a>
## GitHub project links
[GitHubProjectLink]s point to a [GitHub](https://github.com/) page of the
current project (assuming it is stored on GitHub).

You can use the following MarkDown:
[GitHub&rsqb;
[GitHubWiki&rsqb;
[GitHubMilestones&rsqb;
[GitHubReleases&rsqb;
[GitHubPullRequests&rsqb;
[GitHubRaw&rsqb;

You can the following optional attributes:
- suffix: A path suffix e.g. [Github suffix='wiki'&rsqb; is the same as [GithubWiki&rsqb;
- title: An alternative title for the hyperlink. e.g. [GitHubWiki title='Wiki documentation'&rsqb;


<a id='pubdev-project-links'></a>
## PubDev project links
[GitHubProjectLink]s point to a [PubDev](https://pub.dev/) page of the
current project (assuming it is published on PubDev).

You can use the following MarkDown:
[PubDev&rsqb;
[PubDevChangeLog&rsqb;
[PubDevVersions&rsqb;
[PubDevExample&rsqb;
[PubDevInstall&rsqb;
[PubDevScore&rsqb;
[PubDevLicense&rsqb;

You can the following optional attributes:
- suffix: A path suffix e.g. [PubDev suffix='example'&rsqb; is the same as [PubDevExample&rsqb;
- title: An alternative title for the hyperlink. e.g. [PubDevExample title='Examples'&rsqb;


<a id='pubdev-package-links'></a>
## PubDev package links
A library can have members such as a:
- constant
- function
- enum (an enum can have value members)
- class (a class can have members such as methods, fields, and field access methods)
- extension (an extension can have members such as methods, fields, and field access methods)

These library members can be referred to in [MarkdownPage]'s using brackets. e.g.
- [myConstant]
- [myFunction]
- [MyEnum]
  - [MyEnum.myValue]
- [MyClass]
  - [MyClass.myField]
  - [MyClass.get.myField]
  - [MyClass.set.myField]
  - [MyClass.myMethod]
- [MyExtension]
  - [MyClass.myField]
  - [MyExtension.get.myField]
  - [MyExtension.set.myField]
  - [MyExtension.myMethod]
You can also include the library name in case a project uses same member names in different libraries, e.g.:
- [MyLib/myConstant]
- [MyLib/myFunction]
- etc.

The [DocumentationBuilder] will try to resolve these [MemberLink]s in the following order:
- Within the [MarkdownPage], e.g.: link it to the position of a [ImportDartDocTag]
- Within another [WikiMarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
- Link it to a [GitHubProjectCodeLink]
The [Link] will not be replaced when the [Link] can not be resolved
A [PubDevPackageLink] links point to a [PubDev](https://pub.dev) package.

The [DocumentationBuilder] will check if any valid package name
(lower case letter, numbers and underscores) between
square brackets exists as a package on https://pub.dev.

It will be converter to a hyperlink if it exists. e.g.:
- [json_serializable&rsqb; will be replaced by
  [json_serializable&rsqb;(https://pub.dev/packages/json_serializable)
- [none_existent_package] will remain the same.

You can use the optional title attribute, e.g.:
[json_serializable title='Package for json conversion'&rsqb; will be replaced by
[Package for json conversion&rsqb;(https://pub.dev/packages/json_serializable)


 //TODO DartCodeMemberLinkRule
 //TODO MarkDownFileLinkRule
 //TODO PREVIOUS_HOME_NEXT LINKS FOR WIKI PAGES