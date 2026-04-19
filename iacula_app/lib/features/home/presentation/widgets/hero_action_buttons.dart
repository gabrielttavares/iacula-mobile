import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../../favorites/domain/entities/favorite_item.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/quote.dart';

class HeroActionButtons extends StatelessWidget {
  const HeroActionButtons({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroShareButton(quote: quote),
        const SizedBox(width: 8),
        HeroBookmarkButton(quote: quote),
      ],
    );
  }
}

class HeroShareButton extends ConsumerWidget {
  const HeroShareButton({super.key, required this.quote});

  final Quote quote;

  static const _seasonLabels = <LiturgicalSeason, String>{
    LiturgicalSeason.ordinary: 'tempo comum',
    LiturgicalSeason.advent: 'tempo do advento',
    LiturgicalSeason.lent: 'tempo da quaresma',
    LiturgicalSeason.easter: 'tempo pascal',
    LiturgicalSeason.christmas: 'tempo do natal',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton(
      key: const Key('hero_share_button'),
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () async {
        HapticFeedback.selectionClick();

        final isEscrivaPoints =
            quote.resolvedSource == QuoteSource.escrivaPoints;
        final labelText =
            quote.feastName ??
            (isEscrivaPoints
                ? quote.referenceLabel
                : quote.theme == 'personal'
                ? 'frase pessoal'
                : _seasonLabels[quote.season]) ??
            '';

        final renderer = ref.read(heroCardShareImageRendererProvider);
        final imageBytes = await renderer.renderPng(
          context: context,
          payload: HeroCardSharePayload(
            text: quote.text,
            labelText: labelText,
            imagePath: quote.imagePath,
            isEscrivaPoints: isEscrivaPoints,
          ),
        );

        final shareService = ref.read(nativeShareServiceProvider);
        final shareText = '${quote.text}\n\n- Iacula';
        if (imageBytes != null) {
          await shareService.shareTextWithImage(
            text: shareText,
            imageBytes: imageBytes,
            fileName: 'iacula-hero-card.png',
          );
          return;
        }

        await shareService.shareText(shareText);
      },
      child: Icon(
        CupertinoIcons.share,
        color: context.colors.primaryButton,
        size: 20,
      ),
    );
  }
}

class HeroBookmarkButton extends ConsumerWidget {
  const HeroBookmarkButton({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAsync = ref.watch(
      favoriteItemByQuoteTextProvider(quote.text),
    );
    final isSaved = favoriteAsync.valueOrNull != null;
    final savedItem = favoriteAsync.valueOrNull;

    return CupertinoButton(
      key: const Key('hero_bookmark_button'),
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
