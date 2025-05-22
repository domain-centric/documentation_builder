import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('Uri extension methods', () {
    test('should parse query parameters correctly', () {
      final uri = Uri.parse('https://example.com/page?foo=bar&baz=qux');
      uri.queryParameters.should.containKey('foo');
      uri.queryParameters['foo'].should.be('bar');
      uri.queryParameters.should.containKey('baz');
      uri.queryParameters['baz'].should.be('qux');
    });

    test('should resolve relative URIs', () {
      final base = Uri.parse('https://example.com/path/');
      final resolved = base.resolve('subpage');
      resolved.toString().should.be('https://example.com/path/subpage');
    });

    test('should return correct host and scheme', () {
      final uri = Uri.parse('https://example.com:8080/page');
      uri.scheme.should.be('https');
      uri.host.should.be('example.com');
      uri.port.should.be(8080);
    });

    test('should handle fragments', () {
      final uri = Uri.parse('https://example.com/page#section1');
      uri.fragment.should.be('section1');
    });

    test('should encode and decode components', () {
      final original = 'hello world!';
      final encoded = Uri.encodeComponent(original);
      encoded.should.be('hello%20world!');
      final decoded = Uri.decodeComponent(encoded);
      decoded.should.be(original);
    });
  });
}
