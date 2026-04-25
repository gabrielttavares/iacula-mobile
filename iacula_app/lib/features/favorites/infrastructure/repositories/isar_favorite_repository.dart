import 'dart:async';

import 'package:iacula_app/core/storage/isar/favorite_item_doc.dart';
import 'package:iacula_app/core/storage/isar/isar_store.dart';
import 'package:iacula_app/features/favorites/domain/entities/favorite_item.dart';
import 'package:iacula_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:isar/isar.dart';

final class IsarFavoriteRepository implements FavoriteRepository {
  IsarFavoriteRepository({
    IsarStore? store,
    Future<Isar> Function()? isarProvider,
  }) : _isarProvider =
           isarProvider ?? (() async => (store ?? IsarStore.instance).isar);

  final Future<Isar> Function() _isarProvider;
  final _controller = StreamController<List<FavoriteItem>>.broadcast();

  @override
  Future<List<FavoriteItem>> listAll() async {
    final isar = await _isarProvider();
    final docs = await isar.favoriteItemDocs
        .filter()
        .deletedAtIsNull()
        .sortBySavedAtDesc()
        .findAll();
    return docs.map(_toEntity).toList();
  }

  @override
  Stream<List<FavoriteItem>> watchAll() async* {
    yield await listAll();
    yield* _controller.stream;
  }

  @override
  Future<void> save(FavoriteItem item) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = FavoriteItemDoc()
        ..favoriteId = item.id
        ..quoteText = item.quoteText
        ..theme = item.theme
        ..season = item.season
        ..savedAt = item.savedAt.toUtc()
        ..imagePath = item.imagePath
        ..feastName = item.feastName
        ..prayerSlug = item.prayerSlug
        ..referenceLabel = item.referenceLabel
        ..isDirty = true
        ..deletedAt = null;
      await isar.favoriteItemDocs.put(doc);
    });
    _controller.add(await listAll());
  }

  @override
  Future<void> remove(String id) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = await isar.favoriteItemDocs
          .filter()
          .favoriteIdEqualTo(id)
          .findFirst();
      if (doc != null) {
        doc.deletedAt = DateTime.now().toUtc();
        doc.isDirty = true;
        await isar.favoriteItemDocs.put(doc);
      }
    });
    _controller.add(await listAll());
  }

  @override
  Future<bool> isFavorite(String quoteText) async {
    final isar = await _isarProvider();
    final count = await isar.favoriteItemDocs
        .filter()
        .deletedAtIsNull()
        .quoteTextEqualTo(quoteText)
        .count();
    return count > 0;
  }

  static FavoriteItem _toEntity(FavoriteItemDoc doc) {
    return FavoriteItem(
      id: doc.favoriteId,
      quoteText: doc.quoteText,
      theme: doc.theme,
      season: doc.season,
      savedAt: doc.savedAt,
      imagePath: doc.imagePath,
      feastName: doc.feastName,
      prayerSlug: doc.prayerSlug,
      referenceLabel: doc.referenceLabel,
    );
  }
}
