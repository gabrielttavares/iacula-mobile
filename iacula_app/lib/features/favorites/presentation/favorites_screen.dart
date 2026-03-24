import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../domain/entities/favorite_item.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: favoritesAsync.when(
        data: (favorites) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Favoritos'),
                backgroundColor: context.colors.background,
                border: null,
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  ref.invalidate(favoritesProvider);
                  // Allow time for the animation and reload
                  await Future.delayed(const Duration(milliseconds: 500));
                },
              ),
              if (favorites.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: IaculaEmptyState(
                      title: 'Nenhum favorito ainda',
                      message: 'As orações que você salvar aparecerão aqui.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(IaculaSpacing.md),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey<int>(favorites.length),
                        children: [
                          for (int i = 0; i < favorites.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _FavoriteCard(
                                item: favorites[i],
                               onRemove: () async {
                                 HapticFeedback.mediumImpact();
                                 await ref.read(favoriteRepositoryProvider).remove(favorites[i].id);
                                 ref.invalidate(favoritesProvider);
                                },
                                onShare: () async {
                                  HapticFeedback.selectionClick();
                                  await ref
                                      .read(nativeShareServiceProvider)
                                      .shareText('${favorites[i].quoteText}\n\n- Iacula');
                                },
                                onTap: favorites[i].prayerSlug != null
                                    ? () async {
                                        final entry = await ref.read(
                                          prayerEntryBySlugProvider(favorites[i].prayerSlug!)
                                              .future,
                                        );
                                        if (entry != null && context.mounted) {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  PrayerCatalogDetailScreen(
                                                entry: entry,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(IaculaSpacing.md),
          child: IaculaShimmerList(itemCount: 4),
        ),
        error: (error, stackTrace) => const Center(
          child: IaculaErrorState(
            title: 'Erro ao carregar favoritos',
            message: 'Tente novamente em instantes.',
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.onRemove,
    required this.onShare,
    this.onTap,
  });

  final FavoriteItem item;
  final VoidCallback onRemove;
  final VoidCallback onShare;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showCupertinoModalPopup<void>(
          context: context,
          builder: (sheetContext) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onShare();
                },
                child: const Text('Compartilhar'),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onRemove();
                },
                child: const Text('Remover'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text('Cancelar'),
            ),
          ),
        );
      },
      child: IaculaSoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.theme, style: context.textStyles.secondary),
            const SizedBox(height: 4),
            Text(item.quoteText, style: context.textStyles.cardTitle),
            if (item.feastName != null) ...[
              const SizedBox(height: 4),
              Text(item.feastName!, style: context.textStyles.secondary),
            ],
          ],
        ),
      ),
    );
  }
}
