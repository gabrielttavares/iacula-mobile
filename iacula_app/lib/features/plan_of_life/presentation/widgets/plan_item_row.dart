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
    
    return InkWell(
      onTap: () => onToggle(!isCompleted),
      splashColor: const Color(0xFF3D3125).withValues(alpha: 0.3),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF837562).withValues(alpha: 0.15),
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
                          ? const Color(0xFF837562).withValues(alpha: 0.7)
                          : const Color(0xFFF8EFE1),
                      fontSize: 16,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF837562).withValues(alpha: 0.7),
                    ) ??
                    TextStyle(
                      color: isCompleted
                          ? const Color(0xFF837562).withValues(alpha: 0.7)
                          : const Color(0xFFF8EFE1),
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
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
