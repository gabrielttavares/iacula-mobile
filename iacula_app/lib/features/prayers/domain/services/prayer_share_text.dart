import 'prayer_block_parser.dart';

/// Formats a prayer as plain text for messaging apps (WhatsApp markup:
/// `*bold*`, `_italic_`). ℣/℟ become "V." / "R." because the symbols are
/// missing from many Android fonts, and the text ends with a link to the app.
String formatPrayerForSharing({
  required String title,
  required List<String> blocks,
  required String appLink,
}) {
  const parser = PrayerBlockParser();
  final lines = <String>['*$title*'];

  for (final block in parser.parseAll(blocks)) {
    final text = _inline(block.spans);
    switch (block.kind) {
      case PrayerBlockKind.heading:
        lines.add('*$text*');
      case PrayerBlockKind.rubric:
        lines.add(_italic(block.plainText));
      case PrayerBlockKind.versicle:
        lines.add('V. $text');
      case PrayerBlockKind.response:
        lines.add('R. $text');
      case PrayerBlockKind.text:
        lines.add(text);
    }
  }

  lines.add('Rezado com o Iacula 🙏\n$appLink');
  return lines.join('\n\n');
}

String _inline(List<PrayerSpan> spans) => spans
    .map(
      (span) => switch (span.kind) {
        PrayerSpanKind.text => span.text,
        PrayerSpanKind.response => 'R. ${span.text}',
        PrayerSpanKind.rubric || PrayerSpanKind.cue => _italic(span.text),
      },
    )
    .join();

/// WhatsApp italics break across line breaks, so each line is wrapped.
String _italic(String text) => text
    .split('\n')
    .map((line) => line.trim().isEmpty ? line : '_${line.trim()}_')
    .join('\n');
