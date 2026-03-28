import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/widgets/iacula_shimmer.dart';
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
    expect(find.textContaining('Citações'), findsOneWidget);
    expect(find.textContaining('orações'), findsOneWidget);
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
    expect(find.byIcon(CupertinoIcons.chevron_right), findsNothing);
  });

  testWidgets('prayer favorite shows row chevron', (tester) async {
    final repo = InMemoryFavoriteRepository();
    await repo.save(FavoriteItem(
      id: 'prayer:agnus',
      quoteText: 'Agnus Dei',
      theme: 'Oração',
      season: '',
      savedAt: DateTime(2026, 2, 24),
      prayerSlug: 'agnus-dei',
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
    expect(find.text('Agnus Dei'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_right), findsOneWidget);
  });

  testWidgets('quote favorite with image shows thumbnail', (tester) async {
    final repo = InMemoryFavoriteRepository();
    await repo.save(FavoriteItem(
      id: '1',
      quoteText: 'Com imagem.',
      theme: 'Tema',
      season: 'ordinary',
      savedAt: DateTime(2026, 2, 24),
      imagePath: 'assets/seed/images/ordinary/1/E.jpg',
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
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('loading shows large title Favoritos and shimmer', (tester) async {
    final holder = StreamController<List<FavoriteItem>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) {
            ref.onDispose(holder.close);
            return holder.stream;
          }),
        ],
        child: const CupertinoApp(home: FavoritesScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.byType(IaculaShimmerList), findsOneWidget);
  });

  testWidgets('quote favorite shows saved date caption', (tester) async {
    final repo = InMemoryFavoriteRepository();
    await repo.save(FavoriteItem(
      id: '1',
      quoteText: 'Antiga.',
      theme: 'T',
      season: 'ordinary',
      savedAt: DateTime(2020, 3, 15),
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
    expect(find.textContaining('Salvo'), findsOneWidget);
    expect(find.textContaining('15/03'), findsOneWidget);
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
