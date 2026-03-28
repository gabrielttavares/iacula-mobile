import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../domain/entities/favorite_item.dart';

String? _resolveFavoriteAssetPath(String? path) {
  if (path == null) {
    return null;
  }
  final value = path.trim();
  if (value.isEmpty) {
    return null;
  }
  return value.startsWith('/') ? value.substring(1) : value;
}

String _savedAtCaption(DateTime savedAt) {
  final now = DateTime.now();
  final savedDay = DateTime(savedAt.year, savedAt.month, savedAt.day);
  final today = DateTime(now.year, now.month, now.day);
  final diffDays = today.difference(savedDay).inDays;
  if (diffDays == 0) {
    return 'Salvo hoje';
  }
  if (diffDays == 1) {
    return 'Salvo ontem';
  }
  return 'Salvo em ${savedAt.day.toString().padLeft(2, '0')}/${savedAt.month.toString().padLeft(2, '0')}';
}

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
                  await Future.delayed(const Duration(milliseconds: 500));
                },
              ),
              if (favorites.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: IaculaEmptyState(
                      title: 'Nenhum favorito ainda',
                      message:
                          'Citações e orações que você salvar pelo ícone de favorito aparecem aqui.',
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
                                  await ref
                                      .read(favoriteRepositoryProvider)
                                      .remove(favorites[i].id);
                                  ref.invalidate(favoritesProvider);
                                },
                                onShare: () async {
                                  HapticFeedback.selectionClick();
                                  final favorite = favorites[i];
                                  final shareText =
                                      '${favorite.quoteText}\n\n- Iacula';
                                  final imageBytes = await ref
                                      .read(heroCardShareImageRendererProvider)
                                      .renderPng(
                                        context: context,
                                        payload: HeroCardSharePayload(
                                          text: favorite.quoteText,
                                          labelText:
                                              favorite.feastName ?? favorite.theme,
                                          imagePath: favorite.imagePath,
                                        ),
                                      );

                                  final shareService = ref.read(
                                    nativeShareServiceProvider,
                                  );
                                  if (imageBytes != null) {
                                    await shareService.shareTextWithImage(
                                      text: shareText,
                                      imageBytes: imageBytes,
                                      fileName: 'iacula-favorite-card.png',
                                    );
                                    return;
                                  }

                                  await shareService.shareText(shareText);
                                },
                                onTap: favorites[i].prayerSlug != null
                                    ? () async {
                                        final entry = await ref.read(
                                          prayerEntryBySlugProvider(
                                            favorites[i].prayerSlug!,
                                          ).future,
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
                  bottom:
                      MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
                ),
              ),
            ],
          );
        },
        loading: () => CustomScrollView(
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
                await Future.delayed(const Duration(milliseconds: 500));
              },
            ),
            const SliverPadding(
              padding: EdgeInsets.all(IaculaSpacing.md),
              sliver: SliverToBoxAdapter(
                child: IaculaShimmerList(itemCount: 4),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
              ),
            ),
          ],
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
    if (item.prayerSlug != null) {
      return _FavoritePrayerRow(
        item: item,
        onRemove: onRemove,
        onShare: onShare,
        onTap: onTap,
      );
    }
    return _FavoriteQuoteCard(
      item: item,
      onRemove: onRemove,
      onShare: onShare,
    );
  }
}

class _FavoritePrayerRow extends StatelessWidget {
  const _FavoritePrayerRow({
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
      onLongPress: () => _showFavoriteActions(context, onShare, onRemove),
      child: IaculaSoftCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.quoteText, style: context.textStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    _savedAtCaption(item.savedAt),
                    style: context.textStyles.secondary,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteQuoteCard extends StatelessWidget {
  const _FavoriteQuoteCard({
    required this.item,
    required this.onRemove,
    required this.onShare,
  });

  final FavoriteItem item;
  final VoidCallback onRemove;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final imagePath = _resolveFavoriteAssetPath(item.imagePath);
    final contextLine = item.feastName ?? item.theme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showFavoriteActions(context, onShare, onRemove),
      child: IaculaSoftCard(
        child: imagePath != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(IaculaRadius.small),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.homeHeroFallback,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _quoteTexts(context, contextLine)),
                ],
              )
            : _quoteTexts(context, contextLine),
      ),
    );
  }

  Widget _quoteTexts(BuildContext context, String contextLine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.quoteText, style: context.textStyles.cardTitle),
        if (contextLine.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(contextLine, style: context.textStyles.secondary),
        ],
        const SizedBox(height: 4),
        Text(
          _savedAtCaption(item.savedAt),
          style: context.textStyles.secondary,
        ),
      ],
    );
  }
}

void _showFavoriteActions(
  BuildContext context,
  VoidCallback onShare,
  VoidCallback onRemove,
) {
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
}
