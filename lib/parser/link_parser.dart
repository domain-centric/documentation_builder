import 'package:documentation_builder/builders/documentation_builder.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/project/github_project.dart';
import 'package:documentation_builder/project/pub_dev_project.dart';



/// The [LinkParser] searches for [TextNode]'s that contain texts that represent a [Link]
/// It then replaces these [TextNode]'s into a [Link] and additional [TextNode]'s for the remaining text.
class LinkParser extends Parser {
  LinkParser()
      : super([
    //TODO
  ]);
}

//TODO create a abstract LinkRule

/// You can refer to other parts of the documentation using [Link]s.
/// [Link]s are references between [] brackets in [MarkdownPage]s, e.g.: [MyClass]
/// The [DocumentationBuilder] will try to convert these to hyperlinks that point to an existing document on the internet.
/// The [Link] will not be replaced to a hyperlink when the [Link] can not be resolved
///
/// A [Link] has a default title (the text of the hyperlink).
/// You can specify the title attribute when you would like the title to customize the title of the [Link], e.g.:
/// - Default title: [MyClass] can be converted to [MyClass](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)
/// - Custom title:  [MyClass title='Custom Title'] can be converted to [Custom Title](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)
abstract class Link extends ParentNode {
  Link(ParentNode? parent) : super(parent);
}

/// A library can have members such as a:
/// - constant
/// - function
/// - enum (an enum can have value members)
/// - class (a class can have members such as methods, fields, and field access methods)
/// - extension (an extension can have members such as methods, fields, and field access methods)
///
/// These library members can be referred to in [MarkdownPage]'s using brackets. e.g.
/// - [myConstant]
/// - [myFunction]
/// - [MyEnum]
///   - [MyEnum.myValue]
/// - [MyClass]
///   - [MyClass.myField]
///   - [MyClass.get.myField]
///   - [MyClass.set.myField]
///   - [MyClass.myMethod]
/// - [MyExtension]
///   - [MyClass.myField]
///   - [MyExtension.get.myField]
///   - [MyExtension.set.myField]
///   - [MyExtension.myMethod]
/// You can also include the library name in case a project uses same member names in different libraries, e.g.:
/// - [MyLib/myConstant]
/// - [MyLib/myFunction]
/// - etc.
///
/// The [DocumentationBuilder] will try to resolve these [MemberLink]s in the following order:
/// - Within the [MarkdownPage], e.g.: link it to the position of a [ImportDartDocTag]
/// - Within another [WikiMarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
/// - Link it to a [GitHubProjectCodeLink]
/// The [Link] will not be replaced when the [Link] can not be resolved
class MemberLink extends Link {
  MemberLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class MarkDownFileLink extends Link {
  MarkDownFileLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}
/// TODO see [PubDevProject]
abstract class PubDevLink extends Link {
  PubDevLink(ParentNode? parent) : super(parent) {
    //TODO create children
  }
}


class PubDevInstallLink extends PubDevLink {
  PubDevInstallLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class PubDevInstallExample extends PubDevLink {
  PubDevInstallExample(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

/// TODO see [GitHubProject]
abstract class GitHubLink extends Link {
  GitHubLink(ParentNode? parent) : super(parent) {
    //TODO create children
  }
}

class GitHubProjectLink extends GitHubLink {
  GitHubProjectLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class GitHubProjectCodeLink extends GitHubLink {
  GitHubProjectCodeLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class GitHubProjectMileStonesLink extends GitHubLink {
  GitHubProjectMileStonesLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class GitHubProjectWikiLink extends GitHubLink {
  GitHubProjectWikiLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

class GitHubProjectPullRequestLink extends GitHubLink {
  GitHubProjectPullRequestLink(ParentNode? parent,
      Map<String, dynamic> attributeNamesAndValues) : super(parent) {
    //TODO create children
  }
}

///TODO PREVIOUS_HOME_NEXT LINKS FOR WIKI PAGES
