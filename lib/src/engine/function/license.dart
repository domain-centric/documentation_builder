import 'package:template_engine/template_engine.dart';

class LicenseGroup extends FunctionGroup {
  LicenseGroup() : super('Licenses', [MitLicense()]);
}

class MitLicense extends ExpressionFunction<String> {
  MitLicense()
      : super(
            name: "license.mit",
            description:
                'Creates a MIT license text with current year and copyright holder',
            parameters: [
              Parameter<String>(
                  name: 'name',
                  description: 'Name of the copyright holder',
                  presence: Presence.mandatory())
            ],
            function: createMitLicenseText);

  static String createMitLicenseText(
          RenderContext renderContext, Map<String, Object> parameterValues) =>
      'MIT License:\n\n'
      'Copyright (c) ${DateTime.now().year} ${parameterValues['name']}\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\n'
      'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\n'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
}
