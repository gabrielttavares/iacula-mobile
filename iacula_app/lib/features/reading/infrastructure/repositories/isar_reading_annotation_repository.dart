import 'package:isar/isar.dart';

import '../../../../core/storage/isar/isar_store.dart';
import '../../../../core/storage/isar/reading_bookmark_doc.dart';
import '../../../../core/storage/isar/reading_highlight_doc.dart';
import '../../../../core/storage/isar/reading_progress_doc.dart';
import '../../domain/entities/reading_bookmark.dart';
import '../../domain/entities/reading_highlight.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/reading_annotation_repository.dart';

final class IsarReadingAnnotationRepository
    implements ReadingAnnotationRepository {
  IsarReadingAnnotationRepository({
    IsarStore? store,
    Future<Isar> Function()? isarProvider,
  }) : _isarProvider =
           isarProvider ?? (() async => (store ?? IsarStore.instance).isar);

  final Future<Isar> Function() _isarProvider;

  @override
  Future<void> deleteHighlight(String highlightId) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = await isar.readingHighlightDocs
          .filter()
          .highlightIdEqualTo(highlightId)
          .findFirst();
      if (doc != null) {
        await isar.readingHighlightDocs.delete(doc.id);
      }
    });
  }

  @override
  Future<ReadingBookmark?> getBookmark(String documentId) async {
    final isar = await _isarProvider();
    final doc = await isar.readingBookmarkDocs
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (doc == null) return null;
    return ReadingBookmark(
      documentId: doc.documentId,
      blockId: doc.blockId,
      startOffset: doc.startOffset,
      label: doc.label,
      updatedAt: doc.updatedAt,
    );
  }

  @override
  Future<ReadingProgress?> getProgress(String documentId) async {
    final isar = await _isarProvider();
    final doc = await isar.readingProgressDocs
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (doc == null) return null;
    return ReadingProgress(
      documentId: doc.documentId,
      blockId: doc.blockId,
      startOffset: doc.startOffset,
      updatedAt: doc.updatedAt,
    );
  }

  @override
  Future<List<ReadingHighlight>> listHighlights(String documentId) async {
    final isar = await _isarProvider();
    final docs = await isar.readingHighlightDocs
        .filter()
        .documentIdEqualTo(documentId)
        .sortByCreatedAt()
        .findAll();
    return docs
        .map(
          (doc) => ReadingHighlight(
            id: doc.highlightId,
            documentId: doc.documentId,
            blockId: doc.blockId,
            startOffset: doc.startOffset,
            endOffset: doc.endOffset,
            colorKey: doc.colorKey,
            createdAt: doc.createdAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveBookmark(ReadingBookmark bookmark) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = ReadingBookmarkDoc()
        ..documentId = bookmark.documentId
        ..blockId = bookmark.blockId
        ..startOffset = bookmark.startOffset
        ..label = bookmark.label
        ..updatedAt = bookmark.updatedAt.toUtc();
      await isar.readingBookmarkDocs.put(doc);
    });
  }

  @override
  Future<void> saveHighlight(ReadingHighlight highlight) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = ReadingHighlightDoc()
        ..highlightId = highlight.id
        ..documentId = highlight.documentId
        ..blockId = highlight.blockId
        ..startOffset = highlight.startOffset
        ..endOffset = highlight.endOffset
        ..colorKey = highlight.colorKey
        ..createdAt = highlight.createdAt.toUtc();
      await isar.readingHighlightDocs.put(doc);
    });
  }

  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = ReadingProgressDoc()
        ..documentId = progress.documentId
        ..blockId = progress.blockId
        ..startOffset = progress.startOffset
        ..updatedAt = progress.updatedAt.toUtc();
      await isar.readingProgressDocs.put(doc);
    });
  }
}
