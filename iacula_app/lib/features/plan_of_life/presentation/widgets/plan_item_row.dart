import 'package:flutter/material.dart';
import 'animated_checkbox.dart';

class PlanItemRow extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const PlanItemRow({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dividerColor = theme.dividerColor;
    final disabledColor = theme.disabledColor;
    
    return InkWell(
      onTap: () => onToggle(!isCompleted),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: dividerColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: isCompleted
                          ? disabledColor
                          : colorScheme.onSurface,
                      fontSize: 16,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: disabledColor,
                    ) ??
                    TextStyle(
                      color: isCompleted
                          ? disabledColor
                          : colorScheme.onSurface,
                      fontSize: 16,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                child: Text(title),
              ),
            ),
            const SizedBox(width: 16),
            AnimatedCheckbox(
              value: isCompleted,
            ),
          ],
        ),
      ),
    );
  }
}
