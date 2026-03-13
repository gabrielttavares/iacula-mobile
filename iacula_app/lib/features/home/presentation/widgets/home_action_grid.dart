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
    final width = MediaQuery.of(context).size.width * 0.42;

    final cards = [
      _ActionCard(label: 'Orações', onTap: onOpenPrayers),
      _ActionCard(label: 'Liturgia diária', onTap: onOpenLiturgy),
      _ActionCard(label: 'Intenções', onTap: onOpenIntentions),
      _ActionCard(label: 'Exame Diário', onTap: onOpenExamination),
    ];

    return SizedBox(
      height: _ActionCard._cardHeight,
      child: ListView.separated(
        key: const Key('home_action_grid'),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) =>
            SizedBox(width: width, child: cards[index]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.label, required this.onTap});

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
