import 'package:documentation_builder/src/builder/documentation_model_builder.dart';
import 'package:test/test.dart';

main() {
  group('class: $WikiFileFactory', () {
    test('method: ', () {
      var factory = WikiFileFactory();
      assert(!factory.canCreateFor('test.mdt'));
      assert(!factory.canCreateFor('test.MDT'));
      assert(!factory.canCreateFor('doc/test.mdt'));
      assert(!factory.canCreateFor('doc/test.MDT'));
      assert(!factory.canCreateFor('test.jpg'));
      assert(!factory.canCreateFor('test.pdf'));
      assert(!factory.canCreateFor('test.JPG'));
      assert(factory.canCreateFor('doc/test.jpg'));
      assert(factory.canCreateFor('doc/test.pdf'));
      assert(factory.canCreateFor('doc/test.JPG'));
    });
  });
}
