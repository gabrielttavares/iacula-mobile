import 'dart:async';

import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/favorite_repository.dart';

final class InMemoryFavoriteRepository implements FavoriteRepository {
  final _items = <String, FavoriteItem>{};
  final _controller = StreamController<List<FavoriteItem>>.broadcast();

  @override
  Future<List<FavoriteItem>> listAll() async {
    final sorted = _items.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return sorted;
  }

  @override
  Stream<List<FavoriteItem>> watchAll() async* {
    yield await listAll();
    yield* _controller.stream;
  }

  @override
  Future<void> save(FavoriteItem item) async {
    _items[item.id] = item;
    _controller.add(await listAll());
  }

  @override
  Future<void> remove(String id) async {
    _items.remove(id);
    _controller.add(await listAll());
  }

  @override
  Future<bool> isFavorite(String quoteText) async {
    return _items.values.any((item) => item.quoteText == quoteText);
  }
}
