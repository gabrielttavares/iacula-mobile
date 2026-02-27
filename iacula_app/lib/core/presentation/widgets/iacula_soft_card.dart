import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaSoftCard extends StatelessWidget {
  const IaculaSoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IaculaSpacing.md),
    this.radius = IaculaRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: IaculaColors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: IaculaShadows.card,
      ),
      child: child,
    );
  }
}
