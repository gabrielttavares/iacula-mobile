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

class IaculaEmptyState extends StatefulWidget {
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
  State<IaculaEmptyState> createState() => _IaculaEmptyStateState();
}

class _IaculaEmptyStateState extends State<IaculaEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(curved);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: IaculaSoftCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: context.textStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: IaculaSpacing.xs),
                Text(
                  widget.message,
                  style: context.textStyles.secondary,
                  textAlign: TextAlign.center,
                ),
                if (widget.action != null) ...[
                  const SizedBox(height: IaculaSpacing.md),
                  widget.action!,
                ],
              ],
            ),
          ),
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
