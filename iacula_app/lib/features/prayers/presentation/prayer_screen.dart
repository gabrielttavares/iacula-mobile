import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../more/infrastructure/app_store_review.dart';
import '../domain/entities/prayer.dart';
import '../domain/services/prayer_share_text.dart';
import 'widgets/devotional_prayer_text.dart';
import 'widgets/font_size_controls.dart';

/// Angelus / Regina Caeli as devotional blocks: ℣/℟ pairs, the Hail Mary
/// between the Angelus versicles, and "Oremos" on its own line.
List<String> devotionalBlocks(Prayer prayer) {
  final blocks = <String>[];
  for (var i = 0; i < prayer.verses.length; i++) {
    final verse = prayer.verses[i];
    blocks.add('℣ ${verse.verse}');
    if (verse.response.isNotEmpty) blocks.add('℟ ${verse.response}');
    if (prayer.type == 'angelus' && i < prayer.verses.length - 1) {
      blocks.add('_Ave-Maria…_');
    }
  }
  final closing = prayer.prayer.trim();
  final oremus = RegExp(r'^(Oremos|Orémus)\.?\s*').firstMatch(closing);
  if (oremus != null) {
    blocks
      ..add(oremus.group(1)!)
      ..add(closing.substring(oremus.end));
  } else if (closing.isNotEmpty) {
    blocks.add(closing);
  }
  return blocks;
}

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key, required this.prayer});

  final Prayer prayer;

  String _buildShareText() => formatPrayerForSharing(
    title: prayer.title,
    blocks: devotionalBlocks(prayer),
    appLink: iaculaStoreUrl(defaultTargetPlatform),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(prayerFontSizeProvider).valueOrNull ?? 15.0;

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (prayer.imagePath != null)
            Image.asset(
              prayer.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.black.withValues(alpha: 0.3),
                  CupertinoColors.black.withValues(alpha: 0.86),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.back,
                              size: 18,
                              color: context.colors.primaryButton,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Orações',
                              style: TextStyle(
                                color: context.colors.primaryButton,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.only(right: 8),
                            minimumSize: const Size(28, 28),
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              final shareText = _buildShareText();
                              final imageBytes = await ref
                                  .read(heroCardShareImageRendererProvider)
                                  .renderPng(
                                    context: context,
                                    payload: HeroCardSharePayload(
                                      text: prayer.title,
                                      labelText: prayer.type,
                                      imagePath: prayer.imagePath,
                                    ),
                                  );

                              final shareService = ref.read(
                                nativeShareServiceProvider,
                              );

                              if (imageBytes != null) {
                                await shareService.shareTextWithImage(
                                  text: shareText,
                                  imageBytes: imageBytes,
                                  fileName: 'iacula-prayer-card.png',
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
                          ),
                          const FontSizeControls(isDarkBackground: true),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    prayer.title,
                    style: context.textStyles.sectionTitle.copyWith(
                      fontSize: fontSize + 7,
                      color: context.colors.primaryButton,
                    ),
                  ),
                  const SizedBox(height: IaculaSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      // The text sits on a darkened image: use the dark
                      // palette so ℣/℟ and rubrics stay legible.
                      child: CupertinoTheme(
                        data: CupertinoTheme.of(
                          context,
                        ).copyWith(brightness: Brightness.dark),
                        child: DevotionalPrayerText(
                          blocks: devotionalBlocks(prayer),
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
