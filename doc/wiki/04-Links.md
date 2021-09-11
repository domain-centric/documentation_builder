[//]: # (This file was generated from: doc/template/04-Links.mdt using the documentation_builder package on: 2021-09-11 16:16:13.135831.)
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


<a id='markdown-file-links'></a>
## Markdown file links
A [MarkdownFileLink] links point to an other [GeneratedMarkdownFile].

The [DocumentationBuilder] will try to find this [GeneratedMarkdownFile] and
replace the link to a hyperlink with an absolute Url.

You can use :
- the template name e.g.: [README.mdt&rsqb;
- the output name e.g.: [README.md&rsqb;
- the [ProjectFilePath], e.g.: [doc/template/README.md&rsqb;
- an optional optional title attribute, e.g.:
[README.mdt title='About this project'&rsqb;

Note that the [DocumentationBuilder] ignores letter casing.


 //TODO DartCodeMemberLinkRule
 //TODO MarkDownFileLinkRule
 //TODO PREVIOUS_HOME_NEXT LINKS FOR WIKI PAGES