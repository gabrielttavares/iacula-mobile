import 'package:isar/isar.dart';
import '../../../../core/storage/isar/isar_store.dart';
import '../../../../core/storage/isar/media_asset_doc.dart';
import '../../domain/entities/media_asset.dart';
import '../../domain/repositories/media_catalog_repository.dart';

final class IsarMediaCatalogRepository implements MediaCatalogRepository {
  IsarMediaCatalogRepository(this._store);

  final IsarStore _store;

  @override
  Future<void> upsertAll(List<MediaAsset> assets) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      for (final asset in assets) {
        final doc = MediaAssetDoc()
          ..assetPath = asset.assetPath
          ..type = asset.type
          ..season = asset.season
          ..dayOfWeek = asset.dayOfWeek
          ..language = asset.language;
        await isar.mediaAssetDocs.putByAssetPath(doc);
      }
    });
  }

  @override
  Future<List<MediaAsset>> listByType(String type) async {
    final isar = await _store.isar;
    final all = await isar.mediaAssetDocs.where().findAll();
    final docs = all.where((d) => d.type == type).toList(growable: false);
    return docs
        .map((d) => MediaAsset(
              assetPath: d.assetPath,
              type: d.type,
              season: d.season,
              dayOfWeek: d.dayOfWeek,
              language: d.language,
            ))
        .toList(growable: false);
  }
}


