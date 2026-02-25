import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/favorites/domain/entities/favorite_item.dart';

void main() {
  test('FavoriteItem stores quote text and metadata', () {
    final item = FavoriteItem(
      id: 'fav-1',
      quoteText: 'Deus é amor.',
      theme: 'Amor',
      season: 'ordinary',
      savedAt: DateTime(2026, 2, 24),
    );
    expect(item.quoteText, 'Deus é amor.');
    expect(item.theme, 'Amor');
    expect(item.id, 'fav-1');
  });

  test('two FavoriteItems with same quoteText have same contentKey', () {
    final a = FavoriteItem(
      id: 'a',
      quoteText: 'Same quote.',
      theme: 'T',
      season: 's',
      savedAt: DateTime(2026, 1, 1),
    );
    final b = FavoriteItem(
      id: 'b',
      quoteText: 'Same quote.',
      theme: 'T',
      season: 's',
      savedAt: DateTime(2026, 2, 2),
    );
    expect(a.contentKey, b.contentKey);
  });
}
