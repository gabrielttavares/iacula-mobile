import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/favorites/domain/entities/favorite_item.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import 'package:iacula_app/features/favorites/presentation/favorites_screen.dart';

void main() {
  testWidgets('shows empty state when no favorites', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(InMemoryFavoriteRepository()),
        ],
        child: const CupertinoApp(home: FavoritesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhum favorito ainda'), findsOneWidget);
  });

  testWidgets('shows saved favorites', (tester) async {
    final repo = InMemoryFavoriteRepository();
    await repo.save(FavoriteItem(
      id: '1',
      quoteText: 'Deus é amor.',
      theme: 'Amor',
      season: 'ordinary',
      savedAt: DateTime(2026, 2, 24),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(repo),
        ],
        child: const CupertinoApp(home: FavoritesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Deus é amor.'), findsOneWidget);
  });

  testWidgets('can remove a favorite from long-press action sheet', (tester) async {
    final repo = InMemoryFavoriteRepository();
    await repo.save(FavoriteItem(
      id: '1',
      quoteText: 'To remove.',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime(2026, 2, 24),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(repo),
        ],
        child: const CupertinoApp(home: FavoritesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('To remove.'), findsOneWidget);

    await tester.longPress(find.text('To remove.'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    expect(find.textContaining('To remove.'), findsNothing);
  });
}
