import 'package:flutter/cupertino.dart';

import 'iacula_touchable_card.dart';

class PremiumTouchableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final double borderRadius;

  const PremiumTouchableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      scaleFactor: scaleFactor,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
