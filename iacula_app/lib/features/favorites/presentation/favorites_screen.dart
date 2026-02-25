import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/favorite_item.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: favoritesAsync.when(
          data: (favorites) {
            if (favorites.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(IaculaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IaculaLargeTitle('Favoritos'),
                    SizedBox(height: IaculaSpacing.lg),
                    Center(
                      child: Text(
                        'Seus itens salvos aparecerão aqui.',
                        style: IaculaText.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              itemCount: favorites.length + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: IaculaSpacing.md),
                    child: IaculaLargeTitle('Favoritos'),
                  );
                }
                final item = favorites[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FavoriteCard(
                    item: item,
                    onRemove: () {
                      ref.read(favoriteRepositoryProvider).remove(item.id);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => const Center(
            child: Text('Erro ao carregar favoritos.', style: IaculaText.secondary),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, required this.onRemove});

  final FavoriteItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.theme, style: IaculaText.secondary),
                const SizedBox(height: 4),
                Text(item.quoteText, style: IaculaText.cardTitle),
                if (item.feastName != null) ...[
                  const SizedBox(height: 4),
                  Text(item.feastName!, style: IaculaText.secondary),
                ],
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: onRemove,
            child: const Icon(
              CupertinoIcons.delete,
              size: 18,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ],
      ),
    );
  }
}
