import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/prayer.dart';
import 'widgets/font_size_controls.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key, required this.prayer});

  final Prayer prayer;

  String _buildShareText() {
    final versesText = prayer.verses
        .map(
          (verse) => verse.response.isEmpty
              ? verse.verse
              : '${verse.verse}\n${verse.response}',
        )
        .join('\n\n');
    final suffix = prayer.prayer.trim();
    final body = [
      if (versesText.isNotEmpty) versesText,
      if (suffix.isNotEmpty) suffix,
    ].join('\n\n');
    return '${prayer.title}\n\n$body\n\n- Iacula';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();

    return FutureBuilder(
      future: settingsAsync,
      builder: (context, snapshot) {
        final fontSize = snapshot.data?.prayerFontSize ?? 15.0;

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
                                Icon(CupertinoIcons.back,
                                    size: 18, color: context.colors.primaryButton),
                                const SizedBox(width: 4),
                                Text('Orações',
                                    style: TextStyle(
                                        color: context.colors.primaryButton)),
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
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.paddingOf(context).bottom +
                                IaculaSpacing.md,
                          ),
                          itemCount: prayer.verses.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == prayer.verses.length) {
                              return Text(
                                prayer.prayer,
                                style: context.textStyles.readingBody.copyWith(
                                  color: context.colors.textSecondary,
                                  fontSize: fontSize,
                                ),
                              );
                            }

                            final verse = prayer.verses[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verse.verse,
                                  style: context.textStyles.readingBody.copyWith(
                                    fontSize: fontSize,
                                  ),
                                ),
                                if (verse.response.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    verse.response,
                                      style: context.textStyles.readingBody.copyWith(
                                        color: context.colors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                        fontSize: fontSize,
                                      ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
