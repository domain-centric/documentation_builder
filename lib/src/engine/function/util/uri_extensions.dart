import 'package:http/http.dart' as http;

extension UriExtension on Uri {
  Map<String, String>? _appendQueryParameters(
    Map<String, String> original,
    Map<String, String>? additional,
  ) {
    final result = Map<String, String>.from(original);
    if (additional != null) {
      result.addAll(additional);
    }
    return result.isEmpty ? null : result;
  }

  String? _appendFragment(String original, String? additional) {
    if (additional == null) return original.isEmpty ? null : original;
    return '$original$additional';
  }

  Uri append({
    String? path,
    Map<String, String>? query,
    String? fragment,
    String? suffix,
  }) {
    var uri = Uri(
      scheme: scheme,
      userInfo: userInfo,
      host: host,
      port: port,
      path: path != null ? '${this.path}/$path' : this.path,
      queryParameters: _appendQueryParameters(queryParameters, query),
      fragment: _appendFragment(this.fragment, fragment),
    );
    if (suffix == null) {
      return uri;
    }
    return Uri.parse('$uri$suffix');
  }

  Future<bool> canGetWithHttp() async {
    var response = await http.get(this);
    var success = response.statusCode >= 200 && response.statusCode < 400;
    return success;
  }
}
