import 'package:flutter/cupertino.dart';

import '../../../../core/theme/cupertino_tokens.dart';

class AnimatedCheckbox extends StatelessWidget {
  const AnimatedCheckbox({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: value ? IaculaColors.primaryButton : CupertinoColors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: value
              ? IaculaColors.primaryButton
              : CupertinoColors.systemGrey2,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        child: const Icon(
          CupertinoIcons.check_mark,
          size: 16,
          color: CupertinoColors.white,
        ),
      ),
    );
  }
}
