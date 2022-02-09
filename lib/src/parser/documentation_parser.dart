import '../generic/documentation_model.dart';
import 'badge_parser.dart';
import 'link_parser.dart';
import 'parser.dart';
import 'tag_parser.dart';

/// Parses the [DocumentationModel]:
/// See:
/// - [TagParser]
/// - [LinkParser]
class DocumentationParser {
  Future<DocumentationModel> parse(DocumentationModel model) async {
    String warnings = '';
    try {
      await TagParser().parse(model);
    } on ParserWarning catch (parseWarning) {
      warnings += parseWarning.toString();
    }

    try {
      await BadgeParser().parse(model);
    } on ParserWarning catch (parseWarning) {
      warnings += parseWarning.toString();
    }

    try {
      await LinkParser().parse(model);
    } on ParserWarning catch (parseWarning) {
      warnings += parseWarning.toString();
    }

    if (warnings.isNotEmpty) {
      throw ParserWarning(warnings);
    }
    return model;
  }
}
