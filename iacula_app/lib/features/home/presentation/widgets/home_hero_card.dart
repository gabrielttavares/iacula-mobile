import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../favorites/domain/entities/favorite_item.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/quote.dart';

class HomeHeroCard extends ConsumerWidget {
  const HomeHeroCard({
    super.key,
    required this.quote,
    required this.onOpenPremium,
    this.isFallback = false,
  });

  final Quote quote;
  final VoidCallback onOpenPremium;
  final bool isFallback;

  static const _seasonLabels = <LiturgicalSeason, String>{
    LiturgicalSeason.ordinary: 'tempo comum',
    LiturgicalSeason.advent: 'tempo do advento',
    LiturgicalSeason.lent: 'tempo da quaresma',
    LiturgicalSeason.easter: 'tempo pascal',
    LiturgicalSeason.christmas: 'tempo do natal',
  };

  String? _resolveAssetPath(String? path) {
    if (path == null) {
      return null;
    }
    final value = path.trim();
    if (value.isEmpty) {
      return null;
    }
    return value.startsWith('/') ? value.substring(1) : value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = _resolveAssetPath(quote.imagePath);
    final labelText =
        quote.feastName ?? _seasonLabels[quote.season] ?? '';

    return PremiumTouchableCard(
      onTap: onOpenPremium,
      borderRadius: IaculaRadius.banner,
      child: Container(
        key: const Key('home_hero_card'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IaculaRadius.banner),
          boxShadow: [
            BoxShadow(
              color: context.colors.separator,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 240),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(IaculaRadius.banner),
            child: Stack(
              children: [
                Positioned.fill(
                  child: imagePath != null
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) =>
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: context.colors.homeHeroFallback,
                                ),
                              ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colors.homeHeroFallback,
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.colors.homeHeroTop,
                          context.colors.homeHeroBottom,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                            onPressed: () async {
                              final repo = ref.read(favoriteRepositoryProvider);
                              final alreadySaved = await repo.isFavorite(
                                quote.text,
                              );
                              if (!alreadySaved) {
                                await repo.save(
                                  FavoriteItem(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    quoteText: quote.text,
                                    theme: quote.theme,
                                    season: quote.season.name,
                                    savedAt: DateTime.now(),
                                    imagePath: quote.imagePath,
                                    feastName: quote.feastName,
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              CupertinoIcons.bookmark,
                              color: context.colors.primaryButton,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: context.colors.homeHeroText,
                              height: 1.5,
                            ),
                          ),
                          if (isFallback)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Tempo litúrgico indisponível',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.homeHeroSubtext,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 8,
                  child: Text(
                    labelText.toLowerCase(),
                    key: const Key('home_hero_season_label'),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: context.colors.homeHeroLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
