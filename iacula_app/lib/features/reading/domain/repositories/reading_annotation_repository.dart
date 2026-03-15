import '../entities/reading_bookmark.dart';
import '../entities/reading_highlight.dart';
import '../entities/reading_progress.dart';

abstract interface class ReadingAnnotationRepository {
  Future<List<ReadingHighlight>> listHighlights(String documentId);
  Future<void> saveHighlight(ReadingHighlight highlight);
  Future<void> deleteHighlight(String highlightId);
  Future<ReadingBookmark?> getBookmark(String documentId);
  Future<void> saveBookmark(ReadingBookmark bookmark);
  Future<ReadingProgress?> getProgress(String documentId);
  Future<void> saveProgress(ReadingProgress progress);
}
