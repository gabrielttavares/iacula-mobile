import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({
    super.key,
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenRosary,
    required this.onOpenNovenas,
  });

  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenRosary;
  final VoidCallback onOpenNovenas;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_action_grid'),
      children: [
        Row(
          children: [
            Expanded(
              child: _HorizontalFeatureCard(
                icon: CupertinoIcons.book,
                label: 'Orações',
                onTap: onOpenPrayers,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _HorizontalFeatureCard(
                icon: CupertinoIcons.doc_text,
                label: 'Liturgia',
                onTap: onOpenLiturgy,
              ),
            ),
          ],
        ),
        const SizedBox(height: IaculaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _HorizontalFeatureCard(
                icon: CupertinoIcons.heart,
                label: 'Rosário',
                onTap: onOpenRosary,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _HorizontalFeatureCard(
                icon: CupertinoIcons.book_solid,
                label: 'Novenas',
                onTap: onOpenNovenas,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HorizontalFeatureCard extends StatelessWidget {
  const _HorizontalFeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: IaculaColors.primaryButton, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: IaculaText.cardTitle.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
