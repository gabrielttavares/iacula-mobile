import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class HomeContinuationCard extends StatelessWidget {
  const HomeContinuationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        key: const Key('home_continuation_card'),
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: IaculaColors.homeWarmBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.forward_end_alt_fill,
                color: IaculaColors.homeSacredAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: IaculaText.cardTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: IaculaText.secondary),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: IaculaColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
