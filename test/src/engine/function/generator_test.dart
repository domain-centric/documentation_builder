import 'package:shouldly/shouldly.dart';
import 'package:template_engine/template_engine.dart';
import 'package:test/test.dart';
import 'package:documentation_builder/src/engine/function/generator.dart';

import 'util/reference_test.dart';

void main() {
  group('License', () {
    final licenseFunc = License();

    test('returns MIT license text', () async {
      final result = await licenseFunc.function(
        '',
        FakeRenderContext(VariableMap()),
        {'type': 'MIT', 'name': 'John Doe', 'year': 2022},
      );
      result.toString().should.contain('MIT License');
      result.toString().should.contain('John Doe');
      result.toString().should.contain('2022');
    });

    test('returns BSD3 license text', () async {
      final result = await licenseFunc.function(
        '',
        FakeRenderContext(VariableMap()),
        {'type': 'BSD3', 'name': 'Jane Doe', 'year': 2021},
      );
      result.toString().should.contain('3-Clause BSD License');
      result.toString().should.contain('Jane Doe');
      result.toString().should.contain('2021');
    });

    test('throws on unsupported license type', () async {
      try {
        await licenseFunc.function('', FakeRenderContext(VariableMap()), {
          'type': 'Unsupported',
          'name': 'Unknown',
          'year': 2023,
        });
        throw ShouldlyTestFailureError('should throw an error');
      } catch (e) {
        e.should.beOfType<ArgumentError>().toString().should.be(
          "Invalid argument(s) (type): 'Unsupported' is not "
          "on of the supported license types: MIT, BSD3.",
        );
      }
    });

    test('uses current year if year is not provided', () async {
      final now = DateTime.now().year;
      final result = await licenseFunc.function(
        '',
        FakeRenderContext(VariableMap()),
        {'type': 'MIT', 'name': 'NoYear'},
      );
      result.toString().should.contain('$now');
    });
  });

  group('Licenses', () {
    final licenses = Licenses();

    test('findLicenseOnType returns correct license', () {
      licenses.findLicenseOnType('MIT').should.beOfType<MitLicense>();
      licenses.findLicenseOnType('BSD3').should.beOfType<Bsd3License>();
      licenses.findLicenseOnType('bsd3').should.beOfType<Bsd3License>();
      licenses.findLicenseOnType('unknown').should.beNull();
    });

    test('findLicenseOnText returns correct license', () {
      licenses.findLicenseOnText('MIT License').should.beOfType<MitLicense>();
      licenses
          .findLicenseOnText('3-Clause BSD License')
          .should
          .beOfType<Bsd3License>();
      licenses.findLicenseOnText('Some other text').should.beNull();
    });
  });

  group('MitLicense', () {
    final mit = MitLicense();

    test('containsType matches MIT', () {
      Should.satisfyAllConditions([
        () => mit.containsType('MIT License').should.beTrue(),
        () => mit.containsType('mit license').should.beFalse(),
        () => mit.containsType('MIT').should.beTrue(),
        () => mit.containsType('mit').should.beFalse(),
        () => mit.containsType('BSD').should.beFalse(),
      ]);
    });

    test('text returns correct format', () {
      final text = mit.text(2023, 'TestName');
      Should.satisfyAllConditions([
        () => text.should.contain('MIT License'),
        () => text.should.contain('2023'),
        () => text.should.contain('TestName'),
      ]);
    });
  });

  group('Bsd3License', () {
    final bsd = Bsd3License();

    test('containsType matches BSD3', () {
      bsd.containsType('3-Clause BSD License').should.beTrue();
      bsd.containsType('BSD').should.beFalse();
      bsd.containsType('MIT').should.beFalse();
    });

    test('text returns correct format', () {
      final text = bsd.text(2024, 'BSDName');
      text.should.contain('3-Clause BSD License');
      text.should.contain('2024');
      text.should.contain('BSDName');
    });
  });
}
