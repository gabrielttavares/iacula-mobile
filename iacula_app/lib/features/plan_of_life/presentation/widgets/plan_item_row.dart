import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import 'animated_checkbox.dart';

class PlanItemRow extends StatelessWidget {
  const PlanItemRow({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
  });

  final String title;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: IaculaColors.primaryButton,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: IaculaText.secondary.copyWith(
                    color: isCompleted
                        ? IaculaColors.textSecondary
                        : IaculaColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: IaculaColors.textSecondary,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
