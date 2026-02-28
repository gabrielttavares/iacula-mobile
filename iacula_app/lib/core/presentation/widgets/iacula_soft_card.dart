import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaSoftCard extends StatelessWidget {
  const IaculaSoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IaculaSpacing.md),
    this.radius = IaculaRadius.card,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow ? IaculaShadows.card : null,
      ),
      child: child,
    );
  }
}
