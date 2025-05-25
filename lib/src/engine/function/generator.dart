// ignore_for_file: deprecated_member_use
import 'package:collection/collection.dart';
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/project/git_hub_project.dart';
import 'package:documentation_builder/src/engine/function/util/table_of_contents.dart';
import 'package:template_engine/template_engine.dart';

class GeneratorFunctions extends FunctionGroup {
  GeneratorFunctions()
    : super('Generator Functions', [
        License(),
        TableOfContents(),
        GitHubMileStones(),
      ]);
}

class GitHubMileStones extends ExpressionFunction {
  static const String stateId = 'state';

  GitHubMileStones()
    : super(
        name: 'gitHubMileStones',
        description:
            'A markdown text of milestones on GitHub. You could use this for the CHANGELOG.md file.',
        exampleExpression:
            "{{gitHubMileStones('test/src/template_engine_template_example_test.dart')}}",
        parameters: [
          Parameter<String>(
            name: stateId,
            description:
                'The state of the milestones, either: ${GitHubMileStonesStates.toValuesString()}',
            presence: Presence.optionalWithDefaultValue('all'),
          ),
        ],
        function: (position, renderContext, parameters) async {
          var stateParameterValue = parameters[stateId] as String;
          var state = GitHubMileStonesStates.fromString(stateParameterValue);
          if (state == null) {
            throw ArgumentError(
              'Invalid state: $stateParameterValue. Must be one of: ${GitHubMileStonesStates.toValuesString()}',
              stateId,
            );
          }
          try {
            var gitHubProject = GitHubProject.of(renderContext);
            var mileStones = await gitHubProject.getMilestones(
              stateParameterValue,
            );
            var links = <String>[];
            for (var mileStone in mileStones.entries) {
              links.add('## [${mileStone.key} Milestone](${mileStone.value})');
            }
            return links.join('$newLine$newLine');
          } catch (e) {
            throw Exception(
              'Error getting milestone information from github.com. Error: $e',
            );
          }
        },
      );
}

class TableOfContents extends ExpressionFunction {
  static const pathId = 'path';
  static const includeFileLinkId = 'includeFileLink';
  static const gitHubWikiId = 'gitHubWiki';
  static const nameId = 'tableOfContents';

  TableOfContents()
    : super(
        name: nameId,
        description:
            'Markdown table of content with links to all markdown chapters '
            '(e.g. # chapter, ## paragraph, ## sub paragraph) of a template file'
            ' or all template files in a folder.',
        parameters: [
          Parameter<String>(
            name: pathId,
            description:
                'A relative project path (always with slash forward) to '
                'a template file (e.g.: doc/template/README.md.template) '
                'or a folder with template files (e.g.: doc/template/doc/wiki)',
            presence: Presence.mandatory(),
          ),
          Parameter<bool>(
            name: includeFileLinkId,
            description:
                'If the title links should be preceded with a link to the file',
            presence: Presence.optionalWithDefaultValue(true),
          ),
          Parameter<bool>(
            name: gitHubWikiId,
            description:
                'Will remove the .md extension from the links so that they work correctly inside gitHub wiki pages',
            presence: Presence.optionalWithDefaultValue(false),
          ),
        ],
        function: (position, renderContext, parameters) async {
          var factory = TableOfContentsFactory();
          var relativePath = parameters[pathId] as String;
          var includeFileLink = parameters[includeFileLinkId] as bool;
          var gitHubWiki = parameters[gitHubWikiId] as bool;
          return factory.createMarkDown(
            renderContext: renderContext,
            relativePath: relativePath,
            includeFileLink: includeFileLink,
            gitHubWiki: gitHubWiki,
          );
        },
      );
}

class License extends ExpressionFunction<String> {
  static Licenses licenses = Licenses();
  License()
    : super(
        name: "license",
        description:
            'Creates a license text for the given type, year and copyright holder',
        parameters: [
          Parameter<String>(
            name: 'type',
            description:
                "Type of license, currently supported: ${licenses.supportedTypes}",
            presence: Presence.mandatory(),
          ),
          Parameter<String>(
            name: 'name',
            description: 'Name of the copyright holder',
            presence: Presence.mandatory(),
          ),
          Parameter<int>(
            name: 'year',
            description:
                'Year of the copyright. It wil use the current year if not defined',
            presence: Presence.optional(),
          ),
        ],
        function:
            (
              String position,
              RenderContext renderContext,
              Map<String, Object> parameterValues,
            ) async {
              var type = parameterValues['type'] as String;
              var name = parameterValues['name'] as String;
              int year =
                  (parameterValues['year'] ?? DateTime.now().year) as int;

              var license = licenses.findLicenseOnType(type);
              if (license == null) {
                throw ArgumentError(
                  "'$type' is not on of the supported license types: ${licenses.supportedTypes}.",
                  'type',
                );
              }
              return license.text(year, name);
            },
      );
}

class Licenses extends DelegatingList<LicenseText> {
  Licenses() : super([MitLicense(), Bsd3License()]);

  String get supportedTypes => map((l) => l.licenseType).join(', ');

  LicenseText? findLicenseOnType(String type) {
    type = type.trim().toUpperCase();
    for (var l in this) {
      if (type == l.licenseType) {
        return l;
      }
    }
    return null;
  }
}

abstract class LicenseText {
  late String licenseType;
  String text(int year, String name);
}

class MitLicense extends LicenseText {
  @override
  String get licenseType => 'MIT';

  @override
  String text(int year, String name) =>
      'Copyright $year $name$newLine$newLine'
      'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:$newLine$newLine'
      'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.$newLine$newLine'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
}

class Bsd3License extends LicenseText {
  @override
  String get licenseType => 'BSD3';

  @override
  String text(int year, String name) =>
      'Copyright $year $name$newLine$newLine'
      'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:$newLine$newLine'
      '1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.$newLine$newLine'
      '2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.$newLine$newLine'
      '3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.$newLine$newLine'
      'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
}
