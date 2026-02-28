import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';
import 'iacula_spring_button.dart';

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
    final height = IaculaMetrics.inputHeight + IaculaSpacing.xs;
    return IaculaSpringButton(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onPressed != null
              ? context.colors.primaryButton
              : context.colors.primaryButton.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: Alignment.center,
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
    final height = IaculaMetrics.inputHeight + IaculaSpacing.xs;
    return IaculaSpringButton(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onPressed != null
              ? context.colors.secondaryButton
              : context.colors.secondaryButton.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: Alignment.center,
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
