import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/entities/custom_phrase.dart';

class PhraseRow extends StatelessWidget {
  const PhraseRow({
    super.key,
    required this.phrase,
    required this.onToggle,
    required this.onTap,
  });

  final CustomPhrase phrase;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrayer = phrase.isPrayerAlarm;
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isPrayer ? CupertinoIcons.book : CupertinoIcons.quote_bubble,
              size: 20,
              color: phrase.isActive
                  ? context.colors.primaryButton
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPrayer
                        ? (phrase.prayerTitle ?? phrase.text)
                        : phrase.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.cardTitle.copyWith(
                      fontSize: 15,
                      color: phrase.isActive
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                  // Rotation-mode personal phrases need no subtitle (the section
                  // header already says they're personal); only alarm and
                  // scheduled phrases show their timing.
                  if (isPrayer || !phrase.isRotationMode) ...[
                    const SizedBox(height: 4),
                    Text(
                      isPrayer
                          ? 'Alarme · ${phrase.schedule.summary()}'
                          : phrase.schedule.summary(),
                      style:
                          context.textStyles.secondary.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            CupertinoSwitch(
              value: phrase.isActive,
              onChanged: onToggle,
              activeTrackColor: context.colors.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}
