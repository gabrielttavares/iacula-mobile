import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaListItem extends StatelessWidget {
  const IaculaListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE7E7EC),
              ),
            ),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.textStyles.secondary),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.bookmark,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
