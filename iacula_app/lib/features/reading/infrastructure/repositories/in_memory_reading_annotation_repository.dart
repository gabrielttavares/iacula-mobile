import '../../domain/entities/reading_bookmark.dart';
import '../../domain/entities/reading_highlight.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_annotation_repository.dart';

final class InMemoryReadingAnnotationRepository
    implements ReadingAnnotationRepository {
  final Map<String, List<ReadingHighlight>> _highlights = {};
  final Map<String, ReadingBookmark> _bookmarks = {};
  final Map<String, ReadingProgress> _progress = {};

  @override
  Future<void> deleteHighlight(String highlightId) async {
    for (final list in _highlights.values) {
      list.removeWhere((highlight) => highlight.id == highlightId);
    }
  }

  @override
  Future<ReadingBookmark?> getBookmark(String documentId) async =>
      _bookmarks[documentId];

  @override
  Future<ReadingProgress?> getProgress(String documentId) async =>
      _progress[documentId];

  @override
  Future<List<ReadingHighlight>> listHighlights(String documentId) async {
    final list = List<ReadingHighlight>.from(
      _highlights[documentId] ?? const <ReadingHighlight>[],
    );
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<void> saveBookmark(ReadingBookmark bookmark) async {
    _bookmarks[bookmark.documentId] = bookmark;
  }

  @override
  Future<void> saveHighlight(ReadingHighlight highlight) async {
    final list = _highlights.putIfAbsent(
      highlight.documentId,
      () => <ReadingHighlight>[],
    );
    list.removeWhere((entry) => entry.id == highlight.id);
    list.add(highlight);
  }

  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    _progress[progress.documentId] = progress;
  }
}
