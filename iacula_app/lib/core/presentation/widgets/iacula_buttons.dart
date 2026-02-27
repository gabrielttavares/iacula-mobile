import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaPrimaryPillButton extends StatelessWidget {
  const IaculaPrimaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: IaculaMetrics.inputHeight + IaculaSpacing.xs,
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: IaculaColors.primaryButton,
        borderRadius: BorderRadius.circular(
          (IaculaMetrics.inputHeight + IaculaSpacing.xs) / 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class IaculaSecondaryPillButton extends StatelessWidget {
  const IaculaSecondaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: IaculaMetrics.inputHeight + IaculaSpacing.xs,
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: const Color(0xFFE9E9ED),
        borderRadius: BorderRadius.circular(
          (IaculaMetrics.inputHeight + IaculaSpacing.xs) / 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: IaculaColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
