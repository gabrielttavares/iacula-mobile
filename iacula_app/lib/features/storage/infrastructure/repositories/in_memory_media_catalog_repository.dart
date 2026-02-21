import '../../domain/entities/media_asset.dart';
import '../../domain/repositories/media_catalog_repository.dart';

final class InMemoryMediaCatalogRepository implements MediaCatalogRepository {
  final List<MediaAsset> _items = [];

  @override
  Future<void> upsertAll(List<MediaAsset> assets) async {
    for (final asset in assets) {
      _items.removeWhere((i) => i.assetPath == asset.assetPath);
      _items.add(asset);
    }
  }

  @override
  Future<List<MediaAsset>> listByType(String type) async {
    return _items.where((e) => e.type == type).toList(growable: false);
  }
}
