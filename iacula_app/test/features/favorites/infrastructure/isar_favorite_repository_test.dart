import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/storage/isar/favorite_item_doc.dart';
import 'package:iacula_app/features/favorites/domain/entities/favorite_item.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/isar_favorite_repository.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

void main() {
  group('IsarFavoriteRepository', () {
    late Isar isar;
    late IsarFavoriteRepository repo;
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

      tempDir = await Directory.systemTemp.createTemp('iacula-fav-test');
      isar = await Isar.open(
        [FavoriteItemDocSchema],
        directory: tempDir.path,
        name: 'fav_test_${DateTime.now().microsecondsSinceEpoch}',
      );
      repo = IsarFavoriteRepository(isarProvider: () async => isar);
    });

    tearDown(() async {
      if (!Platform.isMacOS) return;
      await isar.close(deleteFromDisk: true);
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('listAll returns empty initially', () async {
      if (!Platform.isMacOS) return;
      expect(await repo.listAll(), isEmpty);
    });

    test('save and listAll returns saved item', () async {
      if (!Platform.isMacOS) return;
      final item = FavoriteItem(
        id: '1',
        quoteText: 'Test',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      );
      await repo.save(item);
      final all = await repo.listAll();
      expect(all, hasLength(1));
      expect(all.first.quoteText, 'Test');
      expect(all.first.id, '1');
    });

    test('remove soft-deletes item so listAll excludes it', () async {
      if (!Platform.isMacOS) return;
      final item = FavoriteItem(
        id: '1',
        quoteText: 'Test',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      );
      await repo.save(item);
      await repo.remove('1');
      expect(await repo.listAll(), isEmpty);
    });

    test('isFavorite returns true for saved quote text', () async {
      if (!Platform.isMacOS) return;
      await repo.save(FavoriteItem(
        id: '1',
        quoteText: 'Saved',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      ));
      expect(await repo.isFavorite('Saved'), true);
      expect(await repo.isFavorite('Not saved'), false);
    });

    test('isFavorite returns false after item is removed', () async {
      if (!Platform.isMacOS) return;
      await repo.save(FavoriteItem(
        id: '1',
        quoteText: 'Saved',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      ));
      await repo.remove('1');
      expect(await repo.isFavorite('Saved'), false);
    });

    test('watchAll emits updates', () async {
      if (!Platform.isMacOS) return;
      final collected = <int>[];
      final sub = repo.watchAll().listen((list) {
        collected.add(list.length);
      });

      await Future<void>.delayed(Duration.zero);

      await repo.save(FavoriteItem(
        id: '1',
        quoteText: 'Test',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      ));

      await Future<void>.delayed(Duration.zero);

      expect(collected, [0, 1]);
      await sub.cancel();
    });

    test('save with same favoriteId replaces existing doc', () async {
      if (!Platform.isMacOS) return;
      await repo.save(FavoriteItem(
        id: '1',
        quoteText: 'Original',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      ));
      await repo.save(FavoriteItem(
        id: '1',
        quoteText: 'Updated',
        theme: 'T',
        season: 'ordinary',
        savedAt: DateTime.utc(2026, 2, 25),
      ));
      final all = await repo.listAll();
      expect(all, hasLength(1));
      expect(all.first.quoteText, 'Updated');
    });
  });
}
