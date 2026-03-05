import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.secondaryButton,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.cardTitle),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.secondary,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
