import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';
import '../widgets/iacula_soft_card.dart';

class IaculaInlineMessage extends StatelessWidget {
  const IaculaInlineMessage({
    super.key,
    required this.message,
    this.color,
  });

  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.warning;
    return Container(
      padding: const EdgeInsets.all(IaculaSpacing.sm),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IaculaRadius.small),
      ),
      child: Text(
        message,
        style: context.textStyles.secondary.copyWith(color: context.colors.textPrimary),
      ),
    );
  }
}

class IaculaEmptyState extends StatelessWidget {
  const IaculaEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IaculaSoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.textStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: IaculaSpacing.xs),
            Text(
              message,
              style: context.textStyles.secondary,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: IaculaSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class IaculaErrorState extends StatelessWidget {
  const IaculaErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return IaculaEmptyState(
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : CupertinoButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
    );
  }
}
