import 'entities/bible_book.dart';

final class BibleChapterLocation {
  const BibleChapterLocation({
    required this.book,
    required this.chapterNumber,
  });

  final BibleBook book;
  final int chapterNumber;

  String get label => '${book.name} $chapterNumber';
}

BibleChapterLocation? getPreviousChapterLocation({
  required List<BibleBook> books,
  required BibleBook currentBook,
  required int currentChapter,
}) {
  if (currentChapter > 1) {
    return BibleChapterLocation(
      book: currentBook,
      chapterNumber: currentChapter - 1,
    );
  }

  final currentIndex = _bookIndex(books, currentBook);
  if (currentIndex <= 0) return null;

  final previousBook = books[currentIndex - 1];
  if (previousBook.chapterCount < 1) return null;

  return BibleChapterLocation(
    book: previousBook,
    chapterNumber: previousBook.chapterCount,
  );
}

BibleChapterLocation? getNextChapterLocation({
  required List<BibleBook> books,
  required BibleBook currentBook,
  required int currentChapter,
}) {
  if (currentChapter < currentBook.chapterCount) {
    return BibleChapterLocation(
      book: currentBook,
      chapterNumber: currentChapter + 1,
    );
  }

  final currentIndex = _bookIndex(books, currentBook);
  if (currentIndex < 0 || currentIndex >= books.length - 1) return null;

  final nextBook = books[currentIndex + 1];
  if (nextBook.chapterCount < 1) return null;

  return BibleChapterLocation(
    book: nextBook,
    chapterNumber: 1,
  );
}

int _bookIndex(List<BibleBook> books, BibleBook currentBook) {
  return books.indexWhere(
    (book) => book.abbrev.toLowerCase() == currentBook.abbrev.toLowerCase(),
  );
}
