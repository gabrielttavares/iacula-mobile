// lib/features/prayer_intentions/presentation/widgets/intention_row.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/entities/prayer_intention.dart';

class IntentionRow extends StatelessWidget {
  const IntentionRow({
    super.key,
    required this.intention,
    this.onTap,
    this.onRespond,
    this.showRespondedDate = false,
  });

  final PrayerIntention intention;
  final VoidCallback? onTap;
  final VoidCallback? onRespond;
  final bool showRespondedDate;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        padding: const EdgeInsets.all(IaculaSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intention.title,
                    style: context.textStyles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (intention.description != null &&
                      intention.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      intention.description!,
                      style: context.textStyles.secondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (showRespondedDate && intention.respondedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Respondida em ${_formatDate(intention.respondedAt!)}',
                      style: context.textStyles.secondary.copyWith(
                        fontSize: 13,
                        color: context.colors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onRespond != null) ...[
              const SizedBox(width: IaculaSpacing.sm),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onRespond?.call();
                },
                child: Icon(
                  CupertinoIcons.check_mark_circled,
                  color: context.colors.success,
                  size: 28,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
