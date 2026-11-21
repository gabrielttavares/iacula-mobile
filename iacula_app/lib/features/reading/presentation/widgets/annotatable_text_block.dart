import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart'
    show
        AdaptiveTextSelectionToolbar,
        ContextMenuButtonItem,
        EditableTextState,
        SelectableText,
        TextSpan;

import '../../../../core/theme/cupertino_tokens.dart';
import '../../../bible/domain/bible_citation.dart';
import '../../domain/entities/reading_highlight.dart';

typedef HighlightSelectionCallback =
    void Function({
      required int startOffset,
      required int endOffset,
      required String selectedText,
      required ReadingHighlight? existingHighlight,
    });

ReadingHighlight? findExactMatchingHighlight(
  List<ReadingHighlight> highlights, {
  required int startOffset,
  required int endOffset,
}) {
  for (final highlight in highlights) {
    if (highlight.startOffset == startOffset &&
        highlight.endOffset == endOffset) {
      return highlight;
    }
  }
  return null;
}

class AnnotatableTextBlock extends StatefulWidget {
  const AnnotatableTextBlock({
    super.key,
    required this.text,
    required this.style,
    required this.highlights,
    required this.onHighlightSelected,
    this.citationParser,
    this.onCitationTap,
  });

  final String text;
  final TextStyle style;
  final List<ReadingHighlight> highlights;
  final HighlightSelectionCallback onHighlightSelected;

  /// When set together with [onCitationTap], Bible citations in [text] become
  /// tappable links (footnote-style).
  final BibleCitationParser? citationParser;
  final ValueChanged<BibleCitation>? onCitationTap;

  @override
  State<AnnotatableTextBlock> createState() => _AnnotatableTextBlockState();
}

class _AnnotatableTextBlockState extends State<AnnotatableTextBlock> {
  List<BibleCitation> _citations = const [];
  List<TapGestureRecognizer> _recognizers = const [];

  @override
  void initState() {
    super.initState();
    _parseCitations();
  }

  @override
  void didUpdateWidget(covariant AnnotatableTextBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.citationParser != widget.citationParser ||
        (oldWidget.onCitationTap == null) != (widget.onCitationTap == null)) {
      _parseCitations();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
  }

  void _parseCitations() {
    _disposeRecognizers();
    final parser = widget.citationParser;
    _citations = parser == null || widget.onCitationTap == null
        ? const []
        : parser.parse(widget.text);
    _recognizers = [
      for (final citation in _citations)
        TapGestureRecognizer()
          ..onTap = () => widget.onCitationTap?.call(citation),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildSpan(context),
      contextMenuBuilder: _buildContextMenu,
    );
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState state) {
    final text = widget.text;
    final selection = state.textEditingValue.selection;
    final buttonItems = <ContextMenuButtonItem>[
      ...state.contextMenuButtonItems,
    ];

    final isValidSelection =
        !selection.isCollapsed &&
        selection.isValid &&
        selection.start >= 0 &&
        selection.end <= text.length &&
        selection.start < selection.end;

    if (isValidSelection) {
      final existingHighlight = findExactMatchingHighlight(
        widget.highlights,
        startOffset: selection.start,
        endOffset: selection.end,
      );
      buttonItems.insert(
        0,
        ContextMenuButtonItem(
          label: existingHighlight == null
              ? 'Destacar'
              : 'Remover destaque',
          onPressed: () {
            widget.onHighlightSelected(
              startOffset: selection.start,
              endOffset: selection.end,
              selectedText: text.substring(selection.start, selection.end),
              existingHighlight: existingHighlight,
            );
            state.hideToolbar();
          },
        ),
      );
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  /// Splits the text at every highlight and citation boundary, so a segment
  /// can be both highlighted and a citation link.
  TextSpan _buildSpan(BuildContext context) {
    final text = widget.text;
    final style = widget.style;
    final highlights = _validHighlights(text);

    if (highlights.isEmpty && _citations.isEmpty) {
      return TextSpan(style: style, children: [TextSpan(text: text)]);
    }

    final cuts = <int>{0, text.length};
    for (final h in highlights) {
      cuts..add(h.startOffset)..add(h.endOffset);
    }
    for (final c in _citations) {
      cuts..add(c.start)..add(c.end);
    }
    final sorted = cuts.toList()..sort();

    final linkColor = context.colors.primaryButton;
    final children = <TextSpan>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final from = sorted[i];
      final to = sorted[i + 1];
      if (from >= to) continue;

      final highlighted = highlights.any(
        (h) => h.startOffset <= from && h.endOffset >= to,
      );
      final citationIndex = _citations.indexWhere(
        (c) => c.start <= from && c.end >= to,
      );

      var segmentStyle = highlighted
          ? style.copyWith(backgroundColor: const Color(0x66FFD54F))
          : null;
      if (citationIndex >= 0) {
        segmentStyle = (segmentStyle ?? style).copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor.withValues(alpha: 0.45),
          decorationStyle: TextDecorationStyle.dotted,
        );
      }

      children.add(
        TextSpan(
          text: text.substring(from, to),
          style: segmentStyle,
          recognizer: citationIndex >= 0 ? _recognizers[citationIndex] : null,
        ),
      );
    }

    return TextSpan(style: style, children: children);
  }

  /// Non-overlapping, in-bounds highlights, in text order.
  List<ReadingHighlight> _validHighlights(String text) {
    final sorted = widget.highlights
        .where(
          (h) =>
              h.startOffset >= 0 &&
              h.endOffset <= text.length &&
              h.startOffset < h.endOffset,
        )
        .toList()
      ..sort((a, b) => a.startOffset.compareTo(b.startOffset));
    final result = <ReadingHighlight>[];
    var cursor = 0;
    for (final h in sorted) {
      if (h.startOffset < cursor) continue;
      result.add(h);
      cursor = h.endOffset;
    }
    return result;
  }
}
