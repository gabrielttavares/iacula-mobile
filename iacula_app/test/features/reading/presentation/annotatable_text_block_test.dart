import 'package:flutter_test/flutter_test.dart';
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
}
