import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:template_engine/template_engine.dart';
import 'package:http/http.dart' as http;

/// Provides project information if the projects is stored on https://github.com
class GitHubProject {
  final Uri? _uri;

  /// we throw an [Exception] every time because that way we get exceptions where we want them
  Uri get uri {
    if (_uri == null)
      throw Exception('Could not find the project on github.com');
    return _uri;
  }

  GitHubProject._(this._uri);

  static Future<GitHubProject> createForThisProject() async =>
      GitHubProject._(await _createUri());

  /// returns a [Uri] to the where the project is stored on https://github.com
  /// or null when no github information was found
  static Future<Uri?> _createUri() async {
    try {
      var gitConfigFile = File(
        '${LocalProject.directory.path}${Platform.pathSeparator}.git${Platform.pathSeparator}config',
      );
      if (!gitConfigFile.existsSync()) {
        return null;
      }
      var gitConfigContent = gitConfigFile.readAsStringSync();
      var match = RegExp(r'url = (.+)').firstMatch(gitConfigContent);
      if (match == null) {
        return null;
      }

      var repoUrl = match.group(1);
      if (repoUrl == null) {
        return null;
      }

      var dotGitSuffix = RegExp(r'\.git$');
      var repoUrlWithoutDotGitSuffix = repoUrl.replaceAll(dotGitSuffix, '');
      var uri = Uri.parse(repoUrlWithoutDotGitSuffix);
      if (!await uri.canGetWithHttp()) {
        return null;
      }

      return uri;
    } catch (e) {
      return null;
    }
  }

  /// Variable name for [VariableMap]
  static const String id = 'gitHubProject';

  late Uri wikiUri = uri.append(path: 'wiki');

  late Uri starGazersUri = uri.append(path: 'stargazers');

  late Uri issuesUri = uri.append(path: 'issues');

  late Uri milestonesUri = uri.append(path: 'milestones');

  late Uri releasesUri = uri.append(path: 'releases');

  late Uri pullRequestsUri = uri.append(path: 'pulls');

  /// gets the GitHubProject from the [RenderContext.variables] assuming it was put there first.
  static GitHubProject of(RenderContext context) =>
      context.variables[id] as GitHubProject;

  Uri searchUri(String query) =>
      uri.append(path: 'search', query: {'q': query});

  //e.g.: https://github.com/domain-centric/documentation_builder/blob/9e5bd3f6eb6da1dc107faa2fe3a2d19b7c043a8d/lib/src/builder/documentation_builder.dart#L24
  Uri blobUri(
    ProjectFilePath2 path, {

    /// Tag can be:
    /// * a branch name, e.g. main
    /// * a tag name
    /// * a commitHSA, See https://graphite.dev/guides/git-hash
    String tagName = 'main',
    int? lineNr,
  }) => uri.append(
    path: 'blob/$tagName/${path.relativePath}',
    fragment: lineNr == null ? null : 'L$lineNr',
  );

  Uri sourceFileUri(
    ProjectFilePath2 path, {

    /// See https://graphite.dev/guides/git-hash
    String tagName = 'main',
    int? lineNr,
  }) => blobUri(path, tagName: tagName, lineNr: lineNr);

  Uri licenseUri({
    /// See https://graphite.dev/guides/git-hash
    String tagName = 'main',
    int? lineNr,
  }) =>
      blobUri(ProjectFilePath2('LICENSE.md'), tagName: tagName, lineNr: lineNr);

  Future<Map<String, Uri>> getMilestones(String stateParameterValue) async {
    var restApiUri = Uri.parse(
      'https://api.github.com/repos${uri.path}/milestones?state=$stateParameterValue&sort=closed_at&direction=desc',
    );
    var response = await http.get(
      restApiUri,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch milestones: ${response.statusCode}');
    }
    var json = jsonDecode(response.body) as List;
    var mileStones = <String, Uri>{};
    for (var mileStone in json) {
      var htmlUri = mileStone['html_url'];
      var uriToClosedItems = Uri.parse(htmlUri).append(query: {'closed': '1'});
      var title = mileStone['title'];
      mileStones[title] = uriToClosedItems;
    }
    return mileStones;
  }

  String? getLatestCommitSHA() {
    final headFile = File('.git/HEAD');
    if (!headFile.existsSync()) {
      return null;
    }

    final ref = headFile.readAsStringSync();
    final refPath = ref.split(': ')[1].trim();

    final refFile = File('.git/$refPath');
    if (!refFile.existsSync()) {
      return null;
    }

    final latestCommitSha = refFile.readAsStringSync();
    return latestCommitSha.trim();
  }

  late Uri rawUri = Uri.https(
    'raw.githubusercontent.com',
    '${uri.path}/refs/heads/main',
  );
}

enum GitHubMileStonesStates {
  open,
  closed,
  all;

  const GitHubMileStonesStates();

  static String toValuesString() => values.map((e) => e.name).join(', ');

  static GitHubMileStonesStates? fromString(String state) =>
      values.firstWhereOrNull((s) => state.toLowerCase() == s.name);
}
