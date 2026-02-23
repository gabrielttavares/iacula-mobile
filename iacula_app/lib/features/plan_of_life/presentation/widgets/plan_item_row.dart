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
    final disabledColor = theme.disabledColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onToggle(!isCompleted),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Placeholder rounded image/icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.spa_outlined, // A generic icon
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Center (Title + Subtitle)
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: theme.textTheme.bodyLarge?.copyWith(
                          color: isCompleted ? disabledColor : colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: disabledColor,
                        ) ??
                        TextStyle(
                          color: isCompleted ? disabledColor : colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right (AnimatedCheckbox)
                AnimatedCheckbox(value: isCompleted),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
