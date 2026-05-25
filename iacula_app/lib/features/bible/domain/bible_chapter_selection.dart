import 'entities/bible_verse.dart';

final class BibleVerseSegment {
  const BibleVerseSegment({
    required this.verseNumber,
    required this.textStartGlobal,
    required this.textEndGlobal,
  });

  final int verseNumber;
  final int textStartGlobal;
  final int textEndGlobal;
}

final class BibleVerseHighlightRange {
  const BibleVerseHighlightRange({
    required this.verseNumber,
    required this.startOffset,
    required this.endOffset,
  });

  final int verseNumber;
  final int startOffset;
  final int endOffset;
}

List<BibleVerseSegment> buildVerseSegments(List<BibleVerse> verses) {
  final segments = <BibleVerseSegment>[];
  var globalOffset = 0;

  for (final verse in verses) {
    final numberPrefix = '${verse.number}  ';
    globalOffset += numberPrefix.length;

    final textStartGlobal = globalOffset;
    globalOffset += verse.text.length;

    segments.add(
      BibleVerseSegment(
        verseNumber: verse.number,
        textStartGlobal: textStartGlobal,
        textEndGlobal: globalOffset,
      ),
    );

    if (verse != verses.last) {
      globalOffset += 2;
    }
  }

  return segments;
}

List<BibleVerseHighlightRange> mapGlobalSelectionToVerseRanges({
  required List<BibleVerseSegment> segments,
  required int globalStart,
  required int globalEnd,
}) {
  if (globalStart >= globalEnd) return const [];

  final ranges = <BibleVerseHighlightRange>[];
  for (final segment in segments) {
    final overlapStart = globalStart > segment.textStartGlobal
        ? globalStart
        : segment.textStartGlobal;
    final overlapEnd = globalEnd < segment.textEndGlobal
        ? globalEnd
        : segment.textEndGlobal;
    if (overlapStart >= overlapEnd) continue;

    ranges.add(
      BibleVerseHighlightRange(
        verseNumber: segment.verseNumber,
        startOffset: overlapStart - segment.textStartGlobal,
        endOffset: overlapEnd - segment.textStartGlobal,
      ),
    );
  }

  return ranges;
}

String formatBibleSelectionReference({
  required String bookName,
  required int chapterNumber,
  required List<BibleVerseSegment> segments,
  required int globalStart,
  required int globalEnd,
}) {
  final touchedVerses = <int>[];
  for (final segment in segments) {
    if (globalEnd <= segment.textStartGlobal ||
        globalStart >= segment.textEndGlobal) {
      continue;
    }
    touchedVerses.add(segment.verseNumber);
  }

  if (touchedVerses.isEmpty) {
    return '$bookName $chapterNumber';
  }

  touchedVerses.sort();
  final firstVerse = touchedVerses.first;
  final lastVerse = touchedVerses.last;
  if (firstVerse == lastVerse) {
    return '$bookName $chapterNumber,$firstVerse';
  }
  return '$bookName $chapterNumber,$firstVerse-$lastVerse';
}
