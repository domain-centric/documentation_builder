import 'local_project.dart';

/// Provides uri's of the project on https://github.com
class PubDevProject {
  final Uri? uri;

  static PubDevProject _singleton = PubDevProject._();

  factory PubDevProject() => _singleton;

  PubDevProject._() : uri = _createUri();

  /// returns a [Uri] to a project (package) on https://pub.dev
  /// or null when it could not be found on https://pub.dev
  static Uri? _createUri() {
    Uri uri = Uri(
        scheme: 'https',
        host: 'pub.dev',
        path: '/packages/${LocalProject.name}');
    //TODO test if uri exists, if not return null
    return uri;
  }

  Uri? get changeLogUri => _createUriWithSuffix('changelog');

  Uri? get exampleUri => _createUriWithSuffix('example');

  Uri? get installUri => _createUriWithSuffix('install');

  Uri? get versionsUri => _createUriWithSuffix('versions');

  Uri? get scoreUri => _createUriWithSuffix('score');

  Uri? get licenseUri => _createUriWithSuffix('license');

  _createUriWithSuffix(String suffix) {
    if (uri == null) {
      return null;
    }
    Uri uriWithSuffix = uri!.replace(path: '${uri!.path}/$suffix');
    //TODO test if uriWithSuffix exists otherwise return null
    return uriWithSuffix;
  }
}
