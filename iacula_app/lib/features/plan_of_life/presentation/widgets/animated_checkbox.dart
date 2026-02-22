import 'package:flutter/material.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool value;

  const AnimatedCheckbox({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: value ? colorScheme.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: value ? colorScheme.primary : theme.disabledColor,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.check,
            size: 18,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
