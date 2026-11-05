/// Parses the devotional markup used by prayer blocks
/// (see `tool/prayers/format_prayers.py`):
///
/// - `℣ texto`  versicle, said by whoever leads
/// - `℟ texto`  response, said by everyone (also inline: `São Miguel, ℟ rogai por nós.`)
/// - `# Título` heading inside a prayer
/// - `*texto*`  rubric: an instruction, not prayed (also inline at the end)
/// - `_texto_`  abbreviated prayer cue (e.g. `_Ave-Maria…_`)
/// - anything else is prayer text
library;

enum PrayerBlockKind { text, versicle, response, heading, rubric }

enum PrayerSpanKind { text, response, rubric, cue }

final class PrayerSpan {
  const PrayerSpan(this.kind, this.text);

  final PrayerSpanKind kind;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is PrayerSpan && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);

  @override
  String toString() => '${kind.name}("$text")';
}

final class PrayerBlock {
  const PrayerBlock(this.kind, this.spans);

  final PrayerBlockKind kind;
  final List<PrayerSpan> spans;

  String get plainText => spans.map((s) => s.text).join();

  bool get isRole =>
      kind == PrayerBlockKind.versicle || kind == PrayerBlockKind.response;

  /// Whether the block hands a part to the people (a ℟ line or inline ℟).
  bool get hasResponse =>
      kind == PrayerBlockKind.response ||
      spans.any((s) => s.kind == PrayerSpanKind.response);
}

final class PrayerBlockParser {
  const PrayerBlockParser();

  static final RegExp _inline = RegExp(r'\*([^*]+)\*|_([^_]+)_|℟\s*');

  List<PrayerBlock> parseAll(List<String> blocks) => [
    for (final raw in blocks)
      if (raw.trim().isNotEmpty) parse(raw.trim()),
  ];

  PrayerBlock parse(String block) {
    if (block.startsWith('℣')) {
      return PrayerBlock(
        PrayerBlockKind.versicle,
        _inlineSpans(_stripMarker(block)),
      );
    }
    if (block.startsWith('℟')) {
      return PrayerBlock(
        PrayerBlockKind.response,
        _inlineSpans(_stripMarker(block)),
      );
    }
    if (block.startsWith('# ')) {
      return PrayerBlock(PrayerBlockKind.heading, [
        PrayerSpan(PrayerSpanKind.text, block.substring(2).trim()),
      ]);
    }
    if (block.length > 2 &&
        block.startsWith('*') &&
        block.endsWith('*') &&
        !block.substring(1, block.length - 1).contains('*')) {
      return PrayerBlock(PrayerBlockKind.rubric, [
        PrayerSpan(PrayerSpanKind.rubric, block.substring(1, block.length - 1)),
      ]);
    }
    return PrayerBlock(PrayerBlockKind.text, _inlineSpans(block));
  }

  /// Removes the leading ℣/℟ and any legacy punctuation after it ("℣. ").
  String _stripMarker(String block) =>
      block.substring(1).replaceFirst(RegExp(r'^[\s.: ]+'), '');

  /// Inline rubrics, cues and a mid-line ℟: everything after an inline ℟ is
  /// the people's part.
  List<PrayerSpan> _inlineSpans(String text) {
    final spans = <PrayerSpan>[];
    var cursor = 0;
    var afterResponse = false;

    void addText(String value) {
      if (value.isEmpty) return;
      spans.add(
        PrayerSpan(
          afterResponse ? PrayerSpanKind.response : PrayerSpanKind.text,
          value,
        ),
      );
    }

    for (final match in _inline.allMatches(text)) {
      addText(text.substring(cursor, match.start));
      if (match.group(1) != null) {
        spans.add(PrayerSpan(PrayerSpanKind.rubric, match.group(1)!));
      } else if (match.group(2) != null) {
        spans.add(PrayerSpan(PrayerSpanKind.cue, match.group(2)!));
      } else {
        afterResponse = true;
      }
      cursor = match.end;
    }
    addText(text.substring(cursor));
    return _trimTrailingSpace(spans);
  }

  List<PrayerSpan> _trimTrailingSpace(List<PrayerSpan> spans) {
    if (spans.isEmpty) return spans;
    final last = spans.last;
    final trimmed = last.text.trimRight();
    if (trimmed == last.text) return spans;
    return [
      ...spans.take(spans.length - 1),
      if (trimmed.isNotEmpty) PrayerSpan(last.kind, trimmed),
    ];
  }
}
