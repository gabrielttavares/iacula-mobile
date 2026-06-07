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
    final fontSize = ref.watch(prayerFontSizeProvider).valueOrNull ?? 15.0;

    final iconColor = isDarkBackground
        ? context.colors.primaryButton.withValues(alpha: 0.7)
        : context.colors.textSecondary;

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
                ? context.colors.primaryButton.withValues(alpha: 0.1)
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${fontSize.toInt()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkBackground
                  ? context.colors.primaryButton.withValues(alpha: 0.9)
                  : context.colors.textPrimary,
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
  }

  Future<void> _adjustFontSize(WidgetRef ref, double newSize) async {
    final clampedSize = newSize.clamp(_minFontSize, _maxFontSize);
    final currentSettings = ref.read(settingsProvider).valueOrNull;
    if (currentSettings == null) return;
    await ref.read(updateSettingsUseCaseProvider).call(
          currentSettings.copyWith(prayerFontSize: clampedSize),
        );
    // Invalidate the shared cache; the derived prayerFontSizeProvider and every
    // screen watching it rebuild from the fresh read in one pass.
    ref.invalidate(settingsProvider);
  }
}
