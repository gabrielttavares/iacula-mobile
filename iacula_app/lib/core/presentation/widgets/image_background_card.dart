import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';
import 'premium_touchable_card.dart';

class ImageBackgroundCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageAsset;
  final VoidCallback? onTap;
  final double height;
  final Widget? trailing;

  const ImageBackgroundCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageAsset,
    this.onTap,
    this.height = 180.0,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageAsset != null;
    return PremiumTouchableCard(
      onTap: onTap,
      borderRadius: IaculaRadius.card,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(IaculaRadius.card),
          boxShadow: IaculaShadows.card,
          image: hasImage
              ? DecorationImage(
                  image: AssetImage(imageAsset!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(IaculaRadius.card),
          child: Stack(
            children: [
              // Placeholder color if no image
              if (!hasImage)
                Positioned.fill(
                  child: Container(color: context.colors.background),
                ),
              // Gradient for text readability
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.7,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xCC000000)],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(IaculaSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null) ...[
                      Text(
                        subtitle!,
                        style: context.textStyles.secondary.copyWith(
                          color: const Color(0xFFEBEBEB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: context.textStyles.cardTitle.copyWith(
                              color: hasImage
                                  ? context.colors.primaryButton
                                  : context.colors.title,
                              fontSize:
                                  22, // Lora feels a bit smaller sometimes, bumped up slightly
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: IaculaSpacing.sm),
                          trailing!,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
