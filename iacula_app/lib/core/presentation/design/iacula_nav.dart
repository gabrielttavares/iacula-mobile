import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';
import '../widgets/iacula_large_title.dart';

class IaculaNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const IaculaNavBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(middle: Text(title), trailing: trailing);
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}

class IaculaLargeTitleScaffold extends StatelessWidget {
  const IaculaLargeTitleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(IaculaSpacing.md),
    this.backgroundColor,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor ?? context.colors.background,
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: IaculaLargeTitle(title)),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: IaculaSpacing.md),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
