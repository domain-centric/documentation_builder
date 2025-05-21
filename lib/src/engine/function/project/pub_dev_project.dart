import 'package:documentation_builder/src/engine/function/project/local_project.dart';
import 'package:documentation_builder/src/engine/function/util/uri_extensions.dart';
import 'package:template_engine/template_engine.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Provides project information on a project on https://github.com
class PubDevProject {
  final String packageName;
  final Uri? _uri;

  /// we throw an [Exception] every time because that way we get exceptions where we want them
  Uri get uri {
    if (_uri == null) {
      throw Exception('Could not find the project on pub.dev');
    }
    return _uri;
  }

  PubDevProject._(this.packageName, this._uri);

  static Future<PubDevProject> createForThisProject() async =>
      PubDevProject._(LocalProject.name, await _createUri(LocalProject.name));

  static Future<PubDevProject> createForProject(String packageName) async =>
      PubDevProject._(packageName, await _createUri(packageName));

  /// Variable name for [VariableMap]
  static const String id = 'pubDevProject';

  /// gets the [PubDevProject] from the [RenderContext.variables] assuming it was put there first.
  static PubDevProject of(RenderContext context) =>
      context.variables[id] as PubDevProject;

  /// returns a [Uri] to a project (package) on https://pub.dev
  /// returns null if the project can not be found
  static Future<Uri?> _createUri(String projectName) async {
    var uri =
        Uri(scheme: 'https', host: 'pub.dev', path: '/packages/$projectName');
    if (await uri.canGetWithHttp()) {
      return uri;
    }
    return null;
  }

  Uri get changeLogUri => uri.append(path: 'changelog');

  Uri get exampleUri => uri.append(path: 'example');

  Uri get installUri => uri.append(path: 'install');

  Uri get versionsUri => uri.append(path: 'versions');

  Uri get scoreUri => uri.append(path: 'score');

  Uri get licenseUri => uri.append(path: 'license');

  /// Fetches the pubspec.yaml content for a given package name.
  Future<String?> fetchPubspecYaml() async {
    final String _baseUrl = 'https://pub.dev/api/packages';
    final restApiUri = Uri.parse('$_baseUrl/$packageName');
    try {
      final response = await http.get(restApiUri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['latest']['pubspec']?.toString();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
