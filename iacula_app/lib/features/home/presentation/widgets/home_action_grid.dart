import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({
    super.key,
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenRosary,
    required this.onOpenNovenas,
    required this.onOpenDoctrina,
  });

  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenRosary;
  final VoidCallback onOpenNovenas;
  final VoidCallback onOpenDoctrina;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_action_grid'),
      children: [
        Row(
          children: [
            Expanded(
              child: _SquareFeatureCard(
                icon: CupertinoIcons.book,
                label: 'Orações',
                onTap: onOpenPrayers,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _SquareFeatureCard(
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
              child: _SquareFeatureCard(
                icon: CupertinoIcons.heart,
                label: 'Rosário 📿',
                onTap: onOpenRosary,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            Expanded(
              child: _SquareFeatureCard(
                icon: CupertinoIcons.book_solid,
                label: 'Novenas',
                onTap: onOpenNovenas,
              ),
            ),
          ],
        ),
        const SizedBox(height: IaculaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SquareFeatureCard(
                icon: CupertinoIcons.lightbulb,
                label: 'Doutrina\nCatólica',
                onTap: onOpenDoctrina,
              ),
            ),
            const SizedBox(width: IaculaSpacing.sm),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _SquareFeatureCard extends StatelessWidget {
  const _SquareFeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: IaculaSoftCard(
          radius: 18,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: IaculaColors.primaryButton),
              const SizedBox(height: IaculaSpacing.sm),
              Text(
                label,
                style: IaculaText.cardTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
