import 'dart:io';

import 'package:fluent_regex/fluent_regex.dart';

import 'local_project.dart';

/// Provides uri's of the project on https://github.com
class GitHubProject {
  final Uri? uri;

  static GitHubProject _singleton = GitHubProject._();

  factory GitHubProject() => _singleton;

  GitHubProject._() : uri = _createUri();

  /// returns a [Uri] to the where the project is stored on https://github.com
  /// or null when no github information was found

  static Uri? _createUri() {
    File projectGitConfigFile = File(
        '${LocalProject.directory.path}${Platform.pathSeparator}.git${Platform.pathSeparator}config');
    if (!projectGitConfigFile.existsSync()) {
      return null;
    }
    String configText = projectGitConfigFile.readAsStringSync();
    if (!_configExpression.hasMatch(configText)) {
      print(
          'Unknown format or not a github project in: ${projectGitConfigFile.path}');
      return null;
    }
    Map<String, String?> found =
        _configExpression.findCapturedGroups(configText);
    if (found.isEmpty || found.values.first == null) {
      print('Could not find github path in: ${projectGitConfigFile.path}');
      return null;
    }
    String path = found.values.first!;
    Uri uri = Uri(scheme: 'https', host: 'github.com', path: path);
    //TODO test if uri exists, if not return null
    return uri;
  }

  /// e.g.:
  /// [remote "origin"]
  /// 	url = https://github.com/efficientyboosters/fluent_regex.git
  static FluentRegex _configExpression = FluentRegex()
      .lineBreak()
      .literal('[remote "')
      .wordChar(Quantity.oneOrMoreTimes())
      .literal('"]')
      .lineBreak()
      .whiteSpace(Quantity.zeroOrMoreTimes())
      .literal('url = https://github.com')
      .group(
          FluentRegex().characterSet(
              CharacterSet().addLetters().addLiterals('_/'),
              Quantity.oneOrMoreTimes()),
          type: GroupType.captureUnNamed())
      .literal('.git');

  Uri? get milestonesUri => _createUriWithSuffix('milestones');

  Uri? get versionsUri => _createUriWithSuffix('milestones?state=closed');

  Uri? get pullRequestsUri => _createUriWithSuffix('pulls');

  Uri? get wikiUri => _createUriWithSuffix('wiki');

  Uri? searchUri(String query) => _createUriWithSuffix('search?q=$query');

  _createUriWithSuffix(String suffix) {
    if (uri == null) {
      return null;
    }
    Uri uriWithSuffix = uri!.replace(path: '${uri!.path}/$suffix');
    //TODO test if uriWithSuffix exists otherwise return null
    return uriWithSuffix;
  }
}
