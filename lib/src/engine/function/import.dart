// ignore_for_file: deprecated_member_use
import 'package:documentation_builder/src/builder/new_line.dart';
import 'package:documentation_builder/src/engine/function/util/analyzer.dart';
import 'package:documentation_builder/src/engine/function/util/dart_comment_parser.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart';
import 'package:petitparser/petitparser.dart';
import 'package:template_engine/template_engine.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart'
    as p;

/// [Function]s from the [template_engine] package and this package
/// in an order that makes most sense for documentation_builder
class MergedImportFunctions extends FunctionGroup {
  MergedImportFunctions() : super('Import Functions', createFunctions());

  static List<ExpressionFunction> createFunctions() {
    var functions = <ExpressionFunction>[
      // from template_engine package
      ImportTemplate(),
      // from template_engine package
      ImportPure(),
      // from this package
      ImportCode(),
      ImportDartCode(),
      ImportDartDoc(),
    ];
    var functionNames = functions.map((f) => f.name);
    functions
        .addAll(missingImportFunctionsFromTemplateEnginePackage(functionNames));
    return functions;
  }

  static Iterable<ExpressionFunction<Object>>
      missingImportFunctionsFromTemplateEnginePackage(
              Iterable<String> functionNames) =>
          ImportFunctions().where((f) => !functionNames.contains(f.name));
}

class ImportCode extends ExpressionFunction {
  static const String sourceName = 'source';
  static const String sourceHeaderName = 'sourceHeader';
  static const String languageName = 'language';

  ImportCode()
      : super(
            name: 'importCode',
            description: 'A markdown code block that imports a code file.',
            exampleExpression:
                "{{importCode('test/src/template_engine_template_example_test.dart')}}",
            parameters: [
              Parameter<String>(
                  name: sourceName,
                  description: 'The project path of the code file to import'
                      'This path can be a absolute or relative file path or URI.',
                  presence: Presence.mandatory()),
              Parameter<String>(
                  name: 'language',
                  description:
                      'You can specify the language to optimize syntax highlighting, e.g. html, dart, ruby',
                  presence: Presence.optionalWithDefaultValue('')),
              Parameter<bool>(
                  name: 'sourceHeader',
                  description: 'Adds the source path as a header',
                  presence: Presence.optionalWithDefaultValue(true))
            ],
            function: (position, renderContext, parameters) async {
              try {
                var source = parameters[sourceName] as String;
                var language = parameters[languageName] as String;
                var sourceHeader = parameters[sourceHeaderName] as bool;
                var code = await readSource(source);
                var result = StringBuffer();
                if (sourceHeader) {
                  result.writeln('`$source`');
                }
                result.writeln('```$language');
                result.writeln(code);
                result.writeln('```');
                return result.toString();
              } on Exception catch (e) {
                var message = e
                    .toString()
                    .replaceFirst('Exception: ', '')
                    .replaceAll('\r', '')
                    .replaceAll('\n', '');
                throw Exception('Error importing a pure file: $message');
              }
            });
}

class ImportDartCode extends ExpressionFunction {
  static const String sourceName = 'source';
  static const String sourceHeaderName = 'sourceHeader';
  static const String languageName = 'language';

  ImportDartCode()
      : super(
            name: 'importDartCode',
            description: 'A markdown code block that imports a dart code file.',
            exampleExpression:
                "{{importDartCode('test/src/template_engine_template_example_test.dart')}}",
            parameters: [
              Parameter<String>(
                  name: sourceName,
                  description:
                      'The project path of the dart code file to import.'
                      'This path can be a absolute or relative file path or URI.',
                  presence: Presence.mandatory()),
              Parameter<bool>(
                  name: 'sourceHeader',
                  description: 'Adds the source path as a header',
                  presence: Presence.optionalWithDefaultValue(true))
            ],
            function: (position, renderContext, parameters) async {
              parameters[languageName] = 'dart';
              return ImportCode().function(position, renderContext, parameters);
            });
}

class DartCodePathParameter extends Parameter<String> {
  DartCodePathParameter(String name)
      : super(
            name: name,
            presence: Presence.mandatory(),
            description:
                'A reference to a piece of your Dart source code.$newLine'
                'This could be anything from a whole dart file to one of its members.$newLine'
                'Format: <DartFilePath>|<DartMemberPath>$newLine'
                '* <DartFilePath> (required) is a DartFilePath to a Dart file without dart extension, e.g. lib/my_library.dart$newLine'
                '* #: the <DartFilePath> and <DartMemberPath> are separated with a hash$newLine'
                '* <DartMemberPath> (optional) is a dot separated path to the member inside the Dart file, e.g.:$newLine'
                '  * constant name$newLine'
                '  * function name$newLine'
                '  * enum name$newLine'
                '  * class name$newLine'
                '  * extension name$newLine'
                '$newLine'
                'Examples:$newLine'
                '* lib/my_library.dart$newLine'
                '* lib/my_library.dart|myConstant$newLine'
                '* lib/my_library.dart|myFunction$newLine'
                '* lib/my_library.dart|MyEnum$newLine'
                '* lib/my_library.dart|MyEnum.myValue$newLine'
                '* lib/my_library.dart|MyClass$newLine'
                '* lib/my_library.dart|MyClass.myFieldName$newLine'
                '* lib/my_library.dart|MyClass.myFieldName.get$newLine'
                '* lib/my_library.dart|MyClass.myFieldName.set$newLine'
                '* lib/my_library.dart|MyClass.myMethod$newLine'
                '* lib/my_library.dart|MyExtension$newLine'
                '* lib/my_library.dart|MyExtension.myFieldName$newLine'
                '* lib/my_library.dart|MyExtension.myFieldName.get$newLine'
                '* lib/my_library.dart|MyExtension.myFieldName.set$newLine'
                '* lib/my_library.dart|MyExtension.myMethod$newLine');
}

class ImportDartDoc extends ExpressionFunction {
  static const String sourceName = 'source';
  static const String sourceHeaderName = 'sourceHeader';
  static const String languageName = 'language';

  ImportDartDoc()
      : super(
          name: 'importDartDoc',
          description:
              'A markdown code block that imports dat documentation comments for a given library member from a dart code file.:$newLine'
              '* \\\ will be removed.'
              '* Text between [] in the Dart documentation could represent references.'
              '* These references will be replaced to links if possible or nessasary. This is done in the following order:'
              '  * hyper links, e.g. [Google](https://google.com)$newLine'
              '  * links to pub.dev packages, e.g. [documentation_builder]$newLine'
              '  * links to dart members, e.g. [MyClass] or [myField] or [MyClass.myField]$newLine'
              '* Note that tags have no place in dart documentation comments and will therefore not be resolved. Use references or links instead (see above)',
          exampleExpression:
              "{{ImportDartDoc('test/src/template_engine_template_example_test.dart')}}",
          parameters: [DartCodePathParameter(sourceName)],
          function: readDocumentationComments,
        );

  static Future<String> readDocumentationComments(
    String position,
    RenderContext renderContext,
    Map<String, Object> parameters,
  ) async {
    var path = SourcePath(parameters[sourceName] as String);
    var library = await resolveLibrary(renderContext, path.projectFilePath);

    var foundElement =
        findElementRecursively(library, path.dartLibraryMemberPath!);
    validateIfMemberFound(foundElement, path);

    var docComments = foundElement!.documentationComment ?? '';

    var documentation = await dartDocCommentParser.parseAndRender(
        renderContext, foundElement, docComments);
    validateIfNotEmpty(documentation: documentation, path: path);
    return documentation.value;
  }

  static void validateIfNotEmpty(
      {required Result<String> documentation, required p.SourcePath path}) {
    if (documentation is Failure) {
      throw ArgumentError(
          'Dart member: ${path.dartLibraryMemberPath} in: ${path.projectFilePath} could not be parsed or rendered Error: ${documentation.message}');
    }
    if (documentation.value.trim().isEmpty) {
      throw ArgumentError(
          'Dart member: ${path.dartLibraryMemberPath} has no Dart documentation comments in: ${path.projectFilePath}');
    }
  }

  static final DartDocCommentParser dartDocCommentParser =
      DartDocCommentParser();
}
