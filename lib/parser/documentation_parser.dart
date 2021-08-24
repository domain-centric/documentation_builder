import 'package:documentation_builder/generic/documentation_model.dart';
import 'package:documentation_builder/parser/parser.dart';
import 'package:documentation_builder/parser/tag_parser.dart';


/// Parses the [DocumentationModel]:
/// See:
/// - [TagParser]
/// - [LinkParser]
class DocumentationParser {

  DocumentationModel parse(DocumentationModel model) {
    String warnings='';
    try {
      TagParser().parse(model);
    } on ParserWarning catch (parseWarning) {
      warnings+=parseWarning.toString();
    }
    //TODO LinkParser().replaceNodes(model);
    if (warnings.isNotEmpty) throw ParserWarning(warnings);
    return model;
  }
}


