import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class FontSizeControls extends ConsumerWidget {
  const FontSizeControls({
    super.key,
    this.isDarkBackground = false,
  });

  final bool isDarkBackground;

  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 24.0;
  static const double _step = 1.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();

    return FutureBuilder(
      future: settingsAsync,
      builder: (context, snapshot) {
        final fontSize = snapshot.data?.prayerFontSize ?? 15.0;

            final iconColor = isDarkBackground
            ? IaculaColors.primaryButton.withValues(alpha: 0.7)
            : IaculaColors.textSecondary;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: fontSize > _minFontSize
                  ? () => _adjustFontSize(ref, fontSize - _step)
                  : null,
              child: Text(
                'A-',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fontSize > _minFontSize
                      ? iconColor
                      : iconColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDarkBackground
                    ? IaculaColors.primaryButton.withValues(alpha: 0.1)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${fontSize.toInt()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkBackground
                      ? IaculaColors.primaryButton.withValues(alpha: 0.9)
                      : IaculaColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: fontSize < _maxFontSize
                  ? () => _adjustFontSize(ref, fontSize + _step)
                  : null,
              child: Text(
                'A+',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: fontSize < _maxFontSize
                      ? iconColor
                      : iconColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _adjustFontSize(WidgetRef ref, double newSize) async {
    final clampedSize = newSize.clamp(_minFontSize, _maxFontSize);
    final currentSettings = await ref.read(getSettingsUseCaseProvider).call();
    final updateUseCase = ref.read(updateSettingsUseCaseProvider);

    await updateUseCase.call(
      currentSettings.copyWith(prayerFontSize: clampedSize),
    );

    ref.invalidate(getSettingsUseCaseProvider);
  }
}
