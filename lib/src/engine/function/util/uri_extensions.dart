import 'package:http/http.dart' as http;

final Map<Uri, Future<bool>> _httpGetResults = {};

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
  ///
  /// The request is bounded so an unresponsive server cannot stall a build.
  Future<bool> canGetWithHttp({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final existingResult = _httpGetResults[this];
    if (existingResult != null) {
      return existingResult;
    }

    final result = _canGetWithHttp(timeout);
    _httpGetResults[this] = result;
    try {
      return await result;
    } catch (_) {
      _httpGetResults.remove(this);
      rethrow;
    }
  }

  Future<bool> _canGetWithHttp(Duration timeout) async {
    final client = http.Client();
    try {
      final response = await client.get(this).timeout(timeout);
      return response.statusCode >= 200 && response.statusCode < 400;
    } finally {
      client.close();
    }
  }
}
