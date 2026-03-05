import '../entities/bible_book.dart';
import '../entities/bible_verse.dart';

abstract interface class BibleRepository {
  Future<List<BibleBook>> listBooks();

  Future<List<BibleVerse>> getChapter({
    required String bookAbbrev,
    required int chapterNumber,
  });
}
