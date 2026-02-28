import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import 'animated_checkbox.dart';

class PlanItemRow extends StatelessWidget {
  const PlanItemRow({
    super.key,
    required this.title,
    required this.scheduleSummary,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
  });

  final String title;
  final String scheduleSummary;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () => onToggle(!isCompleted),
        child: IaculaSoftCard(
          radius: 16,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: IaculaText.cardTitle.copyWith(
                        color: isCompleted
                            ? IaculaColors.textSecondary
                            : IaculaColors.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: IaculaColors.textSecondary,
                      ),
                      child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scheduleSummary,
                      style: IaculaText.secondary.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: onEdit,
                child: const Icon(
                  CupertinoIcons.ellipsis_circle,
                  size: 20,
                  color: IaculaColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              AnimatedCheckbox(value: isCompleted),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
