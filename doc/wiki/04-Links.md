[//]: # (This file was generated from: doc/templates/04-Links.mdt using the documentation_builder package on: 2021-09-01 12:59:47.822666.)
<a id='lib-parser-link-parser-dart-link'></a>You can refer to other parts of the documentation using [Link]s.
[Link]s are references between [] brackets in [MarkdownPage]s, e.g.: [MyClass]
The [DocumentationBuilder] will try to convert these to hyperlinks that point to an existing document on the internet.
The [Link] will not be replaced to a hyperlink when the [Link] can not be resolved

A [Link] has a default title (the text of the hyperlink).
You can specify the title attribute when you would like the title to customize the title of the [Link], e.g.:
- Default title: [MyClass] can be converted to [MyClass](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)
- Custom title:  [MyClass title='Custom Title'] can be converted to [Custom Title](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)


TODO all Links