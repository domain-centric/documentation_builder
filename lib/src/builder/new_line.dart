/// Characters for a new line
/// We are using what Linux and thus Git seems to prefer: Carriage Return (\r) Line Feed ($newLine)
const String newLine = '\r\n';

/// converts all Line Feeds ($newLine) to Carriage Return (\r) Line Feed ($newLine)
String normalizeNewLines(String text) =>
    text.replaceAll(newLine, '\n').replaceAll('\n', newLine);
