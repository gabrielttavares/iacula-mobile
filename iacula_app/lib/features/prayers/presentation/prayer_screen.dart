import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/prayer.dart';
import 'widgets/font_size_controls.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key, required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();

    return FutureBuilder(
      future: settingsAsync,
      builder: (context, snapshot) {
        final fontSize = snapshot.data?.prayerFontSize ?? 15.0;

        return CupertinoPageScaffold(
          backgroundColor: IaculaColors.background,
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.back,
                                    size: 18, color: CupertinoColors.white),
                                SizedBox(width: 4),
                                Text('Orações',
                                    style: TextStyle(
                                        color: CupertinoColors.white)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const FontSizeControls(isDarkBackground: true),
                        ],
                      ),
                      Text(
                        prayer.title,
                        style: IaculaText.sectionTitle.copyWith(
                          fontSize: fontSize + 7,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.sm),
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: prayer.verses.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == prayer.verses.length) {
                              return Text(
                                prayer.prayer,
                                style: IaculaText.secondary.copyWith(
                                  color: IaculaColors.textSecondary,
                                  height: 1.5,
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
                                  style: IaculaText.secondary.copyWith(
                                    color: IaculaColors.textPrimary,
                                    height: 1.5,
                                    fontSize: fontSize,
                                  ),
                                ),
                                if (verse.response.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    verse.response,
                                    style: IaculaText.secondary.copyWith(
                                      color: IaculaColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                      height: 1.45,
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
