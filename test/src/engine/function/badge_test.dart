import 'package:shouldly/shouldly.dart';
import 'package:documentation_builder/src/engine/function/badge.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Badge', () {
    test('custom badge creates correct markdown', () {
      final badge = Badge.custom(
        toolTip: 'License',
        label: 'license',
        message: 'MIT',
        color: 'blue',
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[![License](https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });

    test('badge without tooltip omits tooltip in markdown', () {
      final badge = Badge(
        toolTip: null,
        image: Uri.parse('https://img.shields.io/badge/license-MIT-blue'),
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[!(https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });

    test('badge with tooltip includes tooltip in markdown', () {
      final badge = Badge(
        toolTip: 'MIT License',
        image: Uri.parse('https://img.shields.io/badge/license-MIT-blue'),
        link: Uri.parse('https://example.com/license'),
      );
      badge.toString().should.be(
        "[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://example.com/license)",
      );
    });
  });

  group('Parameters', () {
    test('ToolTipParameter has correct name and description', () {
      final param = ToolTipParameter(Presence.optional());
      param.name.should.be('toolTip');
      param.description.should.contain('hoovering over a badge');
    });

    test('LabelParameter has correct name and description', () {
      final param = LabelParameter(Presence.mandatory());
      param.name.should.be('label');
      param.description.should.contain('left text of the badge');
    });

    test('MessageParameter has correct name and description', () {
      final param = MessageParameter(Presence.mandatory());
      param.name.should.be('message');
      param.description.should.contain('right text of the badge');
    });

    test('ColorParameter has correct name and description', () {
      final param = ColorParameter(Presence.optional());
      param.name.should.be('color');
      param.description.should.contain('fill color');
    });

    test('LinkParameter has correct name and description', () {
      final param = LinkParameter(Presence.mandatory());
      param.name.should.be('link');
      param.description.should.contain('Uri that points to a web site page');
    });

    test('LicenseTypeParameter has correct name and description', () {
      final param = LicenseTypeParameter(Presence.optional());
      param.name.should.be('licenseType');
      param.description.should.contain('license type to display');
    });
  });
}
