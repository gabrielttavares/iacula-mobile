import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';

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
        onPressed: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        padding: EdgeInsets.zero,
        color: context.colors.primaryButton,
        borderRadius: BorderRadius.circular(
          (IaculaMetrics.inputHeight + IaculaSpacing.xs) / 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.background,
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
        onPressed: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        padding: EdgeInsets.zero,
        color: context.colors.secondaryButton,
        borderRadius: BorderRadius.circular(
          (IaculaMetrics.inputHeight + IaculaSpacing.xs) / 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
