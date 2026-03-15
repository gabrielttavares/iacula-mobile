import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AdaptiveTextSelectionToolbar,
        ContextMenuButtonItem,
        EditableTextState,
        SelectableText,
        TextSpan;

import '../../domain/entities/reading_highlight.dart';

typedef HighlightSelectionCallback =
    void Function({
      required int startOffset,
      required int endOffset,
      required String selectedText,
    });

class AnnotatableTextBlock extends StatelessWidget {
  const AnnotatableTextBlock({
    super.key,
    required this.text,
    required this.style,
    required this.highlights,
    required this.onHighlightSelected,
  });

  final String text;
  final TextStyle style;
  final List<ReadingHighlight> highlights;
  final HighlightSelectionCallback onHighlightSelected;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildSpan(),
      contextMenuBuilder: _buildContextMenu,
    );
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState state) {
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
      buttonItems.insert(
        0,
        ContextMenuButtonItem(
          label: 'Destacar',
          onPressed: () {
            onHighlightSelected(
              startOffset: selection.start,
              endOffset: selection.end,
              selectedText: text.substring(selection.start, selection.end),
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

  TextSpan _buildSpan() {
    final validHighlights = highlights
        .where(
          (highlight) =>
              highlight.startOffset >= 0 &&
              highlight.endOffset <= text.length &&
              highlight.startOffset < highlight.endOffset,
        )
        .toList(growable: false)
      ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

    if (validHighlights.isEmpty) {
      return TextSpan(style: style, children: [TextSpan(text: text)]);
    }

    final children = <TextSpan>[];
    var cursor = 0;

    for (final highlight in validHighlights) {
      if (highlight.startOffset < cursor) {
        continue;
      }
      if (highlight.startOffset > cursor) {
        children.add(TextSpan(text: text.substring(cursor, highlight.startOffset)));
      }
      children.add(
        TextSpan(
          text: text.substring(highlight.startOffset, highlight.endOffset),
          style: style.copyWith(
            backgroundColor: const Color(0x66FFD54F),
          ),
        ),
      );
      cursor = highlight.endOffset;
    }

    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }

    return TextSpan(style: style, children: children);
  }
}
