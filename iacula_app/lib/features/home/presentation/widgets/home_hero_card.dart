import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../favorites/domain/entities/favorite_item.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/quote.dart';

class HomeHeroCard extends ConsumerWidget {
  const HomeHeroCard({
    super.key,
    required this.quote,
    required this.onTap,
    this.isFallback = false,
  });

  final Quote quote;
  final ValueChanged<Quote> onTap;
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
    final isEscrivaPoints = quote.resolvedSource == QuoteSource.escrivaPoints;
    final imagePath = _resolveAssetPath(quote.imagePath);
    final labelText =
        quote.feastName ??
        (isEscrivaPoints
            ? quote.referenceLabel
            : quote.theme == 'personal'
            ? 'frase pessoal'
            : _seasonLabels[quote.season]) ??
        '';

    return PremiumTouchableCard(
      onTap: () => onTap(quote),
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
                SizedBox(height: 240, width: double.infinity),
                Positioned.fill(
                  child: isEscrivaPoints
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1A2640),
                                const Color(0xFF101B32),
                                const Color(0xFF232346),
                              ],
                              stops: const [0.0, 0.48, 1.0],
                            ),
                          ),
                        )
                      : imagePath != null
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
                if (isEscrivaPoints)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.45, -0.5),
                          radius: 1.05,
                          colors: [
                            Colors.white.withValues(alpha: 0.11),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: isEscrivaPoints ? 0.22 : 0.34,
                      ),
                    ),
                  ),
                ),
                if (!isEscrivaPoints)
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
                Positioned(
                  top: 18,
                  right: 18,
                  child: _HeroBookmarkButton(quote: quote),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: _AutoSizingQuoteText(text: quote.text),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isFallback || isEscrivaPoints)
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

class _AutoSizingQuoteText extends StatelessWidget {
  const _AutoSizingQuoteText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const maxFontSize = 17.0;
    const minFontSize = 12.0;
    const lineHeight = 1.45;

    return LayoutBuilder(
      builder: (context, constraints) {
        var chosenSize = maxFontSize;
        for (var size = maxFontSize; size >= minFontSize; size -= 0.5) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w600,
                color: context.colors.homeHeroText,
                height: lineHeight,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          if (painter.height <= constraints.maxHeight) {
            chosenSize = size;
            break;
          }
        }

        return Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: chosenSize,
            fontWeight: FontWeight.w600,
            color: context.colors.homeHeroText,
            height: lineHeight,
          ),
        );
      },
    );
  }
}

class _HeroBookmarkButton extends ConsumerWidget {
  const _HeroBookmarkButton({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAsync = ref.watch(
      favoriteItemByQuoteTextProvider(quote.text),
    );
    final isSaved = favoriteAsync.valueOrNull != null;
    final savedItem = favoriteAsync.valueOrNull;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () async {
        HapticFeedback.selectionClick();
        final repo = ref.read(favoriteRepositoryProvider);
        if (savedItem != null) {
          await repo.remove(savedItem.id);
        } else {
          await repo.save(
            FavoriteItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      child: IaculaAnimatedIcon(
        icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
        color: context.colors.primaryButton,
        size: 20,
        enableHaptics: false,
      ),
    );
  }
}
