import 'package:http/http.dart' as http;

//// Extension methods for [Uri] to append path, query parameters, and fragment.
/// This allows for more flexible URI manipulation without creating a new Uri object each time.
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

  /// Returns a new Uri. You can optionally appended
  /// * [path]
  /// * [query]
  /// * [fragment]
  /// * or a [suffix] to the end of the Uri.
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

  /// Checks if the URI can be accessed via HTTP GET request.
  Future<bool> canGetWithHttp() async {
    var response = await http.get(this);
    var success = response.statusCode >= 200 && response.statusCode < 400;
    return success;
  }
}
