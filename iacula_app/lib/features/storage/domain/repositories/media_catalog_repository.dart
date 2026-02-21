import '../entities/media_asset.dart';

abstract interface class MediaCatalogRepository {
  Future<void> upsertAll(List<MediaAsset> assets);
  Future<List<MediaAsset>> listByType(String type);
}
