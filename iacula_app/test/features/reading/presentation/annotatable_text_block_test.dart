import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/rendering.dart' show RenderEditable;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/bible/domain/bible_citation.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_highlight.dart';
import 'package:iacula_app/features/reading/presentation/widgets/annotatable_text_block.dart';

void main() {
  test('findExactMatchingHighlight returns an exact range match only', () {
    final highlight = ReadingHighlight(
      id: 'hl-1',
      documentId: 'doc-1',
      blockId: 'block-1',
      startOffset: 2,
      endOffset: 8,
      colorKey: 'default',
      createdAt: DateTime.utc(2026, 3, 14),
    );

    expect(
      findExactMatchingHighlight(
        [highlight],
        startOffset: 2,
        endOffset: 8,
      ),
      highlight,
    );

    expect(
      findExactMatchingHighlight(
        [highlight],
        startOffset: 2,
        endOffset: 7,
      ),
      isNull,
    );

    expect(
      findExactMatchingHighlight(
        [highlight],
        startOffset: 3,
        endOffset: 8,
      ),
      isNull,
    );
  });

  testWidgets('Bible citations become tappable and coexist with highlights', (
    tester,
  ) async {
    const text = 'Faça-se em mim (Lc 1, 38). Amém.';
    final tapped = <BibleCitation>[];
    final highlight = ReadingHighlight(
      id: 'hl-1',
      documentId: 'doc-1',
      blockId: 'block-1',
      startOffset: 0,
      endOffset: 20,
      colorKey: 'default',
      createdAt: DateTime.utc(2026, 11, 4),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: AnnotatableTextBlock(
          text: text,
          style: const TextStyle(fontSize: 16),
          highlights: [highlight],
          onHighlightSelected: ({
            required startOffset,
            required endOffset,
            required selectedText,
            required existingHighlight,
          }) {},
          citationParser: const BibleCitationParser(),
          onCitationTap: tapped.add,
        ),
      ),
    );

    final root = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .textSpan!;
    final spans = <TextSpan>[];
    root.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });

    // Text is preserved exactly (highlight offsets depend on it).
    expect(spans.map((s) => s.text).join(), text);

    final linked = spans.where((s) => s.recognizer != null).toList();
    expect(linked.map((s) => s.text).join(), 'Lc 1, 38');
    // "Lc 1" is both highlighted and a link; ", 38" is only a link.
    expect(linked.first.style?.backgroundColor, isNotNull);
    expect(linked.last.style?.backgroundColor, isNull);

    (linked.first.recognizer! as TapGestureRecognizer).onTap!();
    expect(tapped.single.primary.bookAbbrev, 'Lc');
    expect(tapped.single.primary.firstVerse, 38);
  });

  testWidgets('a real tap on a citation opens it (not text selection)', (
    tester,
  ) async {
    final tapped = <BibleCitation>[];
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: AnnotatableTextBlock(
            text: 'Faça-se em mim (Lc 1, 38). Amém.',
            style: const TextStyle(fontSize: 16),
            highlights: const [],
            onHighlightSelected: ({
              required startOffset,
              required endOffset,
              required selectedText,
              required existingHighlight,
            }) {},
            citationParser: const BibleCitationParser(),
            onCitationTap: tapped.add,
          ),
        ),
      ),
    );

    RenderEditable? editable;
    void visit(RenderObject node) {
      if (node is RenderEditable) {
        editable = node;
        return;
      }
      node.visitChildren(visit);
    }

    visit(tester.renderObject(find.byType(AnnotatableTextBlock)));
    final caret = editable!.getLocalRectForCaret(
      const TextPosition(offset: 19), // inside "Lc 1, 38"
    );
    await tester.tapAt(editable!.localToGlobal(caret.center));
    await tester.pumpAndSettle();

    expect(tapped.single.label, 'Lc 1, 38');
  });
}
