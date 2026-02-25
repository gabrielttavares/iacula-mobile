import '../entities/favorite_item.dart';

abstract interface class FavoriteRepository {
  Future<List<FavoriteItem>> listAll();
  Stream<List<FavoriteItem>> watchAll();
  Future<void> save(FavoriteItem item);
  Future<void> remove(String id);
  Future<bool> isFavorite(String quoteText);
}
