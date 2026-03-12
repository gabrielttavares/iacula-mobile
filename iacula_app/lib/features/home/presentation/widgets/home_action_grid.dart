import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({
    super.key,
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenIntentions,
    required this.onOpenExamination,
  });

  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenIntentions;
  final VoidCallback onOpenExamination;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_action_grid'),
      children: [
        Row(
          children: [
            Expanded(
              child: _HorizontalFeatureCard(
                label: 'Orações',
                onTap: onOpenPrayers,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _HorizontalFeatureCard(
                label: 'Liturgia diária',
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
                label: 'Intenções',
                onTap: onOpenIntentions,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _HorizontalFeatureCard(
                label: 'Exame Diário',
                onTap: onOpenExamination,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HorizontalFeatureCard extends StatelessWidget {
  const _HorizontalFeatureCard({required this.label, required this.onTap});

  static const double _cardHeight = 65;

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight,
      child: PremiumTouchableCard(
        onTap: onTap,
        child: IaculaSoftCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.cardTitle.copyWith(
                fontSize: 15,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
