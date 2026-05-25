import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/bible/domain/bible_chapter_navigation.dart';
import 'package:iacula_app/features/bible/domain/entities/bible_book.dart';

void main() {
  final books = [
    const BibleBook(
      abbrev: 'lc',
      name: 'Lucas',
      chapterCount: 24,
      order: 0,
      testament: BibleTestament.novo,
    ),
    const BibleBook(
      abbrev: 'jo',
      name: 'João',
      chapterCount: 21,
      order: 1,
      testament: BibleTestament.novo,
    ),
  ];

  group('getNextChapterLocation', () {
    test('returns next chapter in same book', () {
      final location = getNextChapterLocation(
        books: books,
        currentBook: books[0],
        currentChapter: 15,
      );

      expect(location?.book.abbrev, 'lc');
      expect(location?.chapterNumber, 16);
      expect(location?.label, 'Lucas 16');
    });

    test('returns first chapter of next book at end of book', () {
      final location = getNextChapterLocation(
        books: books,
        currentBook: books[0],
        currentChapter: 24,
      );

      expect(location?.book.abbrev, 'jo');
      expect(location?.chapterNumber, 1);
      expect(location?.label, 'João 1');
    });

    test('returns null at end of bible', () {
      final location = getNextChapterLocation(
        books: books,
        currentBook: books[1],
        currentChapter: 21,
      );

      expect(location, isNull);
    });
  });

  group('getPreviousChapterLocation', () {
    test('returns previous chapter in same book', () {
      final location = getPreviousChapterLocation(
        books: books,
        currentBook: books[0],
        currentChapter: 15,
      );

      expect(location?.book.abbrev, 'lc');
      expect(location?.chapterNumber, 14);
    });

    test('returns last chapter of previous book at start of book', () {
      final location = getPreviousChapterLocation(
        books: books,
        currentBook: books[1],
        currentChapter: 1,
      );

      expect(location?.book.abbrev, 'lc');
      expect(location?.chapterNumber, 24);
    });

    test('returns null at start of bible', () {
      final location = getPreviousChapterLocation(
        books: books,
        currentBook: books[0],
        currentChapter: 1,
      );

      expect(location, isNull);
    });
  });
}
