import 'builders.dart';

/// You can refer to other parts of the documentation using [Link]s.
/// [Link]s are references between [] brackets in [MarkdownTemplateFile]s, e.g.: [MyClass]
/// The [DocumentationBuilder] will try to convert these to hyperlinks that point to an existing document on the internet.
/// The [Link] will not be replaced to a hyperlink when the [Link] can not be resolved
///
/// A [Link] has a default title (the text of the hyperlink).
/// You can specify the title attribute when you would like the title to customize the title of the [Link], e.g.:
/// - Default title: [MyClass] can be converted to [MyClass](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)
/// - Custom title:  [MyClass title='Custom Title'] can be converted to [Custom Title](https://github.com/my_domain/my_project/blob/main/lib/my_lib.dart)
abstract class Link extends MarkDownText {}

/// Library can have members such as a:
/// - constant
/// - function
/// - enum (an enum can have value members)
/// - class (a class can have members such as methods, fields, and field access methods)
/// - extension (an extension can have members such as methods, fields, and field access methods)
///
/// These library members can be referred to in [MarkdownTemplateFile]'s using brackets. e.g.
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
/// - Within the [MarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
/// - Within another [WikiMarkdownTemplateFile], e.g.: link it to the position of a [ImportDartDocTag]
/// - Link it to a [GitHubProjectCodeLink]
/// The [Link] will not be replaced when the [Link] can not be resolved
class MemberLink extends Link {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class MarkDownFileLink extends Link {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}
/// [PubDevLink]s can be obtained by testing if the following URL exists:
/// https://pub.dev/packages/<project name> e.g: https://pub.dev/packages/fluent_regex
///
/// If so, extended links can append to this link e.g.
/// - https://pub.dev/packages/fluent_regex/changelog
/// - https://pub.dev/packages/fluent_regex/example
/// - https://pub.dev/packages/fluent_regex/install
/// - https://pub.dev/packages/fluent_regex/versions
/// - https://pub.dev/packages/fluent_regex/score
/// - https://pub.dev/packages/fluent_regex/license
abstract class PubDevLink extends Link {

}


class PubDevInstallLink extends PubDevLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class PubDevInstallExample extends PubDevLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

/// [GitHubLink]s can be obtained by reading the <project folder>/.git/config file
///
/// e.g.:
/// [remote "origin"]
/// 	url = https://github.com/efficientyboosters/fluent_regex.git
///
/// (remove .git suffix)
///
/// extended [GitHubLink]s can append to this. e.g.:
/// - https://github.com/efficientyboosters/fluent_regex/milestones
/// - https://github.com/efficientyboosters/fluent_regex/milestones?state=closed
/// - https://github.com/efficientyboosters/fluent_regex/pulls
/// - https://github.com/efficientyboosters/fluent_regex/wiki
/// - https://github.com/efficientyboosters/fluent_regex/search?q=<ThingToFind>
abstract class GitHubLink extends Link {}

class GitHubProjectLink extends GitHubLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class GitHubProjectCodeLink extends GitHubLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class GitHubProjectMileStonesLink extends GitHubLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class GitHubProjectWikiLink extends GitHubLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}

class GitHubProjectPullRequestLink extends GitHubLink {
  @override
  String toMarkDownText() {
    // TODO: implement toMarkDownText
    throw UnimplementedError();
  }
}
