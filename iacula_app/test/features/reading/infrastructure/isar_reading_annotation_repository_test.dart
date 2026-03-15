import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/storage/isar/reading_bookmark_doc.dart';
import 'package:iacula_app/core/storage/isar/reading_highlight_doc.dart';
import 'package:iacula_app/core/storage/isar/reading_progress_doc.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_bookmark.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_highlight.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_progress.dart';
import 'package:iacula_app/features/reading/infrastructure/repositories/isar_reading_annotation_repository.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  group('IsarReadingAnnotationRepository', () {
    late Isar isar;
    late IsarReadingAnnotationRepository repo;
    late Directory tempDir;

    setUp(() async {
      if (!Platform.isMacOS) return;

      await Isar.initializeIsarCore(
        libraries: {
          Abi.current(): p.join(
            Directory.current.path,
            'third_party/isar_flutter_libs/macos/libisar.dylib',
          ),
        },
      );

      tempDir = await Directory.systemTemp.createTemp('iacula-reading-test');
      isar = await Isar.open(
        [
          ReadingHighlightDocSchema,
          ReadingBookmarkDocSchema,
          ReadingProgressDocSchema,
        ],
        directory: tempDir.path,
        name: 'reading_test_${DateTime.now().microsecondsSinceEpoch}',
      );
      repo = IsarReadingAnnotationRepository(isarProvider: () async => isar);
    });

    tearDown(() async {
      if (!Platform.isMacOS) return;
      await isar.close(deleteFromDisk: true);
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('saveHighlight persists exact range data', () async {
      if (!Platform.isMacOS) return;

      await repo.saveHighlight(
        ReadingHighlight(
          id: 'hl-1',
          documentId: 'meditation:med-1',
          blockId: 'section-0-paragraph-0',
          startOffset: 3,
          endOffset: 12,
          colorKey: 'default',
          createdAt: DateTime.utc(2026, 3, 14),
        ),
      );

      final highlights = await repo.listHighlights('meditation:med-1');
      expect(highlights, hasLength(1));
      expect(highlights.first.startOffset, 3);
      expect(highlights.first.endOffset, 12);
    });

    test('saveBookmark replaces the previous bookmark for a document', () async {
      if (!Platform.isMacOS) return;

      await repo.saveBookmark(
        ReadingBookmark(
          documentId: 'leituras:caminho:carater',
          blockId: 'section-0-paragraph-0',
          startOffset: 4,
          label: 'Texto 1',
          updatedAt: DateTime.utc(2026, 3, 14),
        ),
      );
      await repo.saveBookmark(
        ReadingBookmark(
          documentId: 'leituras:caminho:carater',
          blockId: 'section-0-paragraph-1',
          startOffset: 2,
          label: 'Texto 2',
          updatedAt: DateTime.utc(2026, 3, 15),
        ),
      );

      final bookmark = await repo.getBookmark('leituras:caminho:carater');
      expect(bookmark, isNotNull);
      expect(bookmark!.blockId, 'section-0-paragraph-1');
      expect(bookmark.startOffset, 2);
    });

    test('saveProgress replaces the previous progress for a document', () async {
      if (!Platform.isMacOS) return;

      await repo.saveProgress(
        ReadingProgress(
          documentId: 'meditation:med-1',
          blockId: 'summary',
          startOffset: 0,
          updatedAt: DateTime.utc(2026, 3, 14),
        ),
      );
      await repo.saveProgress(
        ReadingProgress(
          documentId: 'meditation:med-1',
          blockId: 'section-0-paragraph-0',
          startOffset: 6,
          updatedAt: DateTime.utc(2026, 3, 15),
        ),
      );

      final progress = await repo.getProgress('meditation:med-1');
      expect(progress, isNotNull);
      expect(progress!.blockId, 'section-0-paragraph-0');
      expect(progress.startOffset, 6);
    });
  });
}
