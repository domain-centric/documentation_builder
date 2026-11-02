// ignore_for_file: deprecated_member_use
import 'package:documentation_builder/documentation_builder.dart';
import 'package:petitparser/petitparser.dart';
import 'package:template_engine/template_engine.dart';
import 'package:documentation_builder/src/engine/function/util/path_parsers.dart'
    as p;

/// [Function]s from the [template_engine] package and this package
/// in an order that makes most sense for documentation_builder
final mergedImportFunctions = FunctionGroup(
  'Import Functions',
  createMergedImportFunctions(),
);

List<FunctionDefinition> createMergedImportFunctions() {
  final functions = <FunctionDefinition>[
    // from template_engine package
    importTemplate,
    // from template_engine package
    importPure,
    // from this package
    importCodeFunction,
    importDartCodeFunction,
    importDartDocFunction,
  ];
  var functionNames = functions.map((f) => f.name);
  functions.addAll(
    missingImportFunctionsFromTemplateEnginePackage(functionNames),
  );
  return functions;
}

class ImportFunctionArgumentName {
  static const String source = 'source';
  static const String sourceHeader = 'sourceHeader';
  static const String language = 'language';
}

Iterable<FunctionDefinition> missingImportFunctionsFromTemplateEnginePackage(
  Iterable<String> functionNames,
) => standardImportFunctions.where((f) => !functionNames.contains(f.name));

/// Imports a file (e.g. html, json, or any other programming related file)
/// from this projects and puts it in a Markdown code block.
final importCodeFunction = FunctionDefinition<String>(
  name: 'importCode',
  documentation: FunctionDefinitionDocumentation(
    description: 'A markdown code block that imports a code file.',
    examples: [
      ExpressionBlockExample(
        (delimiter) =>
            "${delimiter.start}importCode('test/src/template_engine_template_example_test.dart')${delimiter.end}",
      ),
    ],
  ),
  parameters: [
    Parameter<String>(
      name: ImportFunctionArgumentName.source,
      description:
          'The project path of the code file to import'
          'This path can be a absolute or relative file path or URI.',
      presence: PresenceMandatory(),
    ),
    Parameter<String>(
      name: ImportFunctionArgumentName.language,
      description: 'You can specify the language to optimize syntax highlighting, e.g. html, dart, ruby',
      presence: PresenceOptionalWithDefaultValue(''),
    ),
    Parameter<bool>(
      name: ImportFunctionArgumentName.sourceHeader,
      description: 'Adds the source path as a header',
      presence: PresenceOptionalWithDefaultValue(true),
    ),
  ],
  function: (context) async {
    try {
      var source =
          context.argumentValues[ImportFunctionArgumentName.source] as String;
      var language =
          context.argumentValues[ImportFunctionArgumentName.language] as String;
      var sourceHeader =
          context.argumentValues[ImportFunctionArgumentName.sourceHeader]
              as bool;
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
  },
);

/// Reads the source file from the given path and puts it in a Markdown code block.
final importDartCodeFunction = FunctionDefinition<String>(
  name: 'importDartCode',
  documentation: FunctionDefinitionDocumentation(
    description: 'A markdown code block that imports a dart code file.',
    examples: [
      ExpressionBlockExample(
        (delimiter) =>
            "${delimiter.start}importDartCode('test/src/template_engine_template_example_test.dart')${delimiter.end}",
      ),
    ],
  ),
  parameters: [
    Parameter<String>(
      name: ImportFunctionArgumentName.source,
      description:
          'The project path of the dart code file to import.'
          'This path can be a absolute or relative file path or URI.',
      presence: PresenceMandatory(),
    ),
    Parameter<bool>(
      name: 'sourceHeader',
      description: 'Adds the source path as a header',
      presence: PresenceOptionalWithDefaultValue(true),
    ),
  ],
  function: (context) async {
    context.argumentValues[ImportFunctionArgumentName.language] = 'dart';
    return importCodeFunction.function(context);
  },
);

/// An [ExpressionFunction]-[Parameter] for a Dart code path.
class DartCodePathParameter extends Parameter<String> {
  DartCodePathParameter(String name)
    : super(
        name: name,
        presence: PresenceMandatory(),
        description:
            'A reference to a piece of your Dart source code.$newLine'
            'This could be anything from a whole dart file to one of its members.$newLine$newLine'
            'Format: &lt;DartFilePath>#&lt;DartMemberPath>$newLine$newLine'
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
            '* lib/my_library.dart#myConstant$newLine'
            '* lib/my_library.dart#myFunction$newLine'
            '* lib/my_library.dart#MyEnum$newLine'
            '* lib/my_library.dart#MyEnum.myValue$newLine'
            '* lib/my_library.dart#MyClass$newLine'
            '* lib/my_library.dart#MyClass.myFieldName$newLine'
            '* lib/my_library.dart#MyClass.myFieldName.get$newLine'
            '* lib/my_library.dart#MyClass.myFieldName.set$newLine'
            '* lib/my_library.dart#MyClass.myMethod$newLine'
            '* lib/my_library.dart#MyExtension$newLine'
            '* lib/my_library.dart#MyExtension.myFieldName$newLine'
            '* lib/my_library.dart#MyExtension.myFieldName.get$newLine'
            '* lib/my_library.dart#MyExtension.myFieldName.set$newLine'
            '* lib/my_library.dart#MyExtension.myMethod$newLine',
      );
}

/// Imports Dart documentation comments for a given library member from a dart code file
/// And converts them to a Markdown
final importDartDocFunction = FunctionDefinition<String>(
  name: 'importDartDoc',
  documentation: FunctionDefinitionDocumentation(
    description:
        'A markdown code block that imports dat documentation comments for a given library member from a dart code file.:$newLine$newLine'
        '* /// will be removed.$newLine'
        '* Text between [] in the Dart documentation could represent references.$newLine'
        '* These references will be replaced to links if possible or nessasary. This is done in the following order:$newLine'
        '  * hyper links, e.g. [Google](https://google.com)$newLine'
        '  * links to pub.dev packages, e.g. [documentation_builder]$newLine'
        '  * links to dart members, e.g. [MyClass] or [myField] or [MyClass.myField]$newLine'
        '* Note that tags have no place in dart documentation comments and will therefore not be resolved. Use references or links instead (see above)$newLine',
    examples: [
      ExpressionBlockExample(
        (delimiter) =>
            "${delimiter.start}ImportDartDoc('test/src/template_engine_template_example_test.dart')${delimiter.end}",
      ),
    ],
  ),
  parameters: [DartCodePathParameter(ImportFunctionArgumentName.source)],
  function: readDocumentationComments,
);

Future<String> readDocumentationComments(FunctionCallContext context) async {
  var path = SourcePath(
    context.argumentValues[ImportFunctionArgumentName.source] as String,
  );
  var library = await resolveLibrary(
    context.renderContext,
    path.projectFilePath,
  );

  var foundElement = findElementRecursively(
    library,
    path.dartLibraryMemberPath!,
  );
  validateIfMemberFound(foundElement, path);

  var docComments = foundElement!.documentationComment ?? '';

  var documentation = await _dartDocCommentParser.parseAndRender(
    context.renderContext,
    foundElement,
    docComments,
  );
  validateIfNotEmpty(documentation: documentation, path: path);
  return documentation.value;
}

void validateIfNotEmpty({
  required Result<String> documentation,
  required p.SourcePath path,
}) {
  if (documentation is Failure) {
    throw ArgumentError(
      'Dart member: ${path.dartLibraryMemberPath} in: ${path.projectFilePath} could not be parsed or rendered Error: ${documentation.message}',
    );
  }
  if (documentation.value.trim().isEmpty) {
    throw ArgumentError(
      'Dart member: ${path.dartLibraryMemberPath} has no Dart documentation comments in: ${path.projectFilePath}',
    );
  }
}

final DartDocCommentParser _dartDocCommentParser = DartDocCommentParser();
