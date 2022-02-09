import '../generic/paths.dart';
import '../parser/link_parser.dart';
import 'local_project.dart';

/// Provides uri's of the project on https://github.com
class PubDevProject {
  final Uri? uri;

  static final PubDevProject _singleton = PubDevProject._();

  factory PubDevProject() => _singleton;

  PubDevProject._() : uri = _createUri(LocalProject.name);

  PubDevProject.forProjectName(String projectName)
      : uri = _createUri(projectName);

  /// returns a [Uri] to a project (package) on https://pub.dev
  /// or null when it could not be found on https://pub.dev
  static Uri? _createUri(String projectName) {
    Uri uri =
        Uri(scheme: 'https', host: 'pub.dev', path: '/packages/$projectName');
    // would be nice if we could return null if the uri did not exist
    // but we can't since it is a async call and _createUri is used in constructor
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
    } else {
      return uri!.withPathSuffix(suffix);
    }
  }

  List<LinkDefinition> get linkDefinitions => [
        LinkDefinition(
            name: 'PubDev',
            defaultTitle: 'PubDev package',
            uri: PubDevProject().uri!),
        LinkDefinition(
            name: 'PubDevChangeLog',
            defaultTitle: 'PubDev change log',
            uri: PubDevProject().changeLogUri!),
        LinkDefinition(
            name: 'PubDevVersions',
            defaultTitle: 'PubDev versions',
            uri: PubDevProject().versionsUri!),
        LinkDefinition(
            name: 'PubDevExample',
            defaultTitle: 'PubDev example',
            uri: PubDevProject().exampleUri!),
        LinkDefinition(
            name: 'PubDevInstall',
            defaultTitle: 'PubDev installation',
            uri: PubDevProject().installUri!),
        LinkDefinition(
            name: 'PubDevScore',
            defaultTitle: 'PubDev score',
            uri: PubDevProject().scoreUri!),
        LinkDefinition(
            name: 'PubDevLicense',
            defaultTitle: 'PubDev license',
            uri: PubDevProject().licenseUri!),
      ];
}
