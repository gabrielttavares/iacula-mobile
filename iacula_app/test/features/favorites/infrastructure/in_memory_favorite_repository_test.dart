import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/favorites/domain/entities/favorite_item.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';

void main() {
  late InMemoryFavoriteRepository repo;

  setUp(() {
    repo = InMemoryFavoriteRepository();
  });

  test('listAll returns empty initially', () async {
    expect(await repo.listAll(), isEmpty);
  });

  test('save and listAll returns saved item', () async {
    final item = FavoriteItem(
      id: '1',
      quoteText: 'Test',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime.now(),
    );
    await repo.save(item);
    final all = await repo.listAll();
    expect(all, hasLength(1));
    expect(all.first.quoteText, 'Test');
  });

  test('remove deletes item', () async {
    final item = FavoriteItem(
      id: '1',
      quoteText: 'Test',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime.now(),
    );
    await repo.save(item);
    await repo.remove('1');
    expect(await repo.listAll(), isEmpty);
  });

  test('isFavorite returns true for saved quote text', () async {
    await repo.save(FavoriteItem(
      id: '1',
      quoteText: 'Saved',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime.now(),
    ));
    expect(await repo.isFavorite('Saved'), true);
    expect(await repo.isFavorite('Not saved'), false);
  });

  test('watchAll emits updates', () async {
    final collected = <int>[];
    final sub = repo.watchAll().listen((list) {
      collected.add(list.length);
    });

    // Allow initial emission to propagate
    await Future<void>.delayed(Duration.zero);

    final item = FavoriteItem(
      id: '1',
      quoteText: 'Test',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime.now(),
    );
    await repo.save(item);

    // Allow save emission to propagate
    await Future<void>.delayed(Duration.zero);

    expect(collected, [0, 1]);
    await sub.cancel();
  });
}
