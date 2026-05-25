import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/bible/domain/bible_chapter_selection.dart';
import 'package:iacula_app/features/bible/domain/entities/bible_verse.dart';

void main() {
  final verses = [
    const BibleVerse(number: 28, text: 'First verse text.'),
    const BibleVerse(number: 29, text: 'Second verse text.'),
    const BibleVerse(number: 30, text: 'Third verse text.'),
  ];

  late List<BibleVerseSegment> segments;

  setUp(() {
    segments = buildVerseSegments(verses);
  });

  test('buildVerseSegments tracks verse text offsets after number prefix', () {
    expect(segments, hasLength(3));
    expect(segments[0].verseNumber, 28);
    expect(segments[0].textStartGlobal, 4);
    expect(segments[0].textEndGlobal, 4 + verses[0].text.length);
    expect(segments[1].textStartGlobal, segments[0].textEndGlobal + 2 + 4);
  });

  test('mapGlobalSelectionToVerseRanges splits selection across verses', () {
    final firstVerseTailStart = segments[0].textEndGlobal - 6;
    final secondVerseHeadEnd = segments[1].textStartGlobal + 7;

    final ranges = mapGlobalSelectionToVerseRanges(
      segments: segments,
      globalStart: firstVerseTailStart,
      globalEnd: secondVerseHeadEnd,
    );

    expect(ranges, hasLength(2));
    expect(ranges[0].verseNumber, 28);
    expect(ranges[0].startOffset, verses[0].text.length - 6);
    expect(ranges[0].endOffset, verses[0].text.length);
    expect(ranges[1].verseNumber, 29);
    expect(ranges[1].startOffset, 0);
    expect(ranges[1].endOffset, 7);
  });

  test('formatBibleSelectionReference uses verse range when multiple verses', () {
    final reference = formatBibleSelectionReference(
      bookName: 'Lucas',
      chapterNumber: 15,
      segments: segments,
      globalStart: segments[0].textStartGlobal,
      globalEnd: segments[1].textEndGlobal,
    );

    expect(reference, 'Lucas 15,28-29');
  });
}
