import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' show SelectableText;

import '../../domain/bible_citation.dart';
import '../bible_citation_sheet.dart';

/// Liturgy of the Hours and Compline cite psalms by the Hebrew numbering and
/// often by whole chapter ("Sl 110", "Salmo 4").
const liturgyReferenceParser = BibleCitationParser(
  psalmNumbering: PsalmNumbering.hebrew,
  allowWholeChapter: true,
);

/// Text whose Bible citations ("Jo 20,1", "Sl 63,2-9") open the verse in a
/// footnote-style sheet. Used wherever the app shows Scripture references
/// outside the book reader: quote detail, Liturgy of the Hours, Compline.
class CitationLinkedText extends StatefulWidget {
  const CitationLinkedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.linkColor,
    this.parser = const BibleCitationParser(),
    this.selectable = true,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  /// Defaults to the text color, so links on images stay legible; links are
  /// always marked with a dotted underline.
  final Color? linkColor;
  final BibleCitationParser parser;
  final bool selectable;

  @override
  State<CitationLinkedText> createState() => _CitationLinkedTextState();
}

class _CitationLinkedTextState extends State<CitationLinkedText> {
  List<BibleCitation> _citations = const [];
  List<TapGestureRecognizer> _recognizers = const [];

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(covariant CitationLinkedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.parser != widget.parser) {
      _parse();
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _parse() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _citations = widget.parser.parse(widget.text);
    _recognizers = [
      for (final citation in _citations)
        TapGestureRecognizer()
          ..onTap = () => showBibleCitationSheet(context, citation),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final linkColor = widget.linkColor ?? base.color;
    final span = TextSpan(
      style: base,
      children: citationSpans(
        text: widget.text,
        citations: _citations,
        recognizers: _recognizers,
        linkStyle: base.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: (linkColor ?? const Color(0xFF888888)).withValues(
            alpha: 0.7,
          ),
        ),
      ),
    );
    return widget.selectable
        ? SelectableText.rich(span, textAlign: widget.textAlign)
        : Text.rich(span, textAlign: widget.textAlign);
  }
}

/// Splits [text] into plain spans and tappable citation spans.
List<InlineSpan> citationSpans({
  required String text,
  required List<BibleCitation> citations,
  required List<TapGestureRecognizer> recognizers,
  required TextStyle linkStyle,
}) {
  final spans = <InlineSpan>[];
  var cursor = 0;
  for (var i = 0; i < citations.length; i++) {
    final c = citations[i];
    if (c.start > cursor) spans.add(TextSpan(text: text.substring(cursor, c.start)));
    spans.add(
      TextSpan(
        text: text.substring(c.start, c.end),
        style: linkStyle,
        recognizer: recognizers[i],
      ),
    );
    cursor = c.end;
  }
  if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
  return spans;
}
