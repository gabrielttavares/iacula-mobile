import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/cupertino_tokens.dart';

/// A single shimmer rectangle placeholder.
class IaculaShimmerBox extends StatelessWidget {
  const IaculaShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = IaculaRadius.small,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.separator,
      highlightColor: context.colors.placeholder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.separator,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A card-shaped shimmer skeleton that mimics [IaculaSoftCard].
class IaculaShimmerCard extends StatelessWidget {
  const IaculaShimmerCard({
    super.key,
    this.height = 120,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return IaculaShimmerBox(
      height: height,
      borderRadius: IaculaRadius.card,
    );
  }
}

/// A column of shimmer rows that mimics a list of [IaculaListItem].
class IaculaShimmerList extends StatelessWidget {
  const IaculaShimmerList({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < itemCount; i++) ...[
          if (i > 0) const SizedBox(height: IaculaSpacing.xs),
          const IaculaShimmerBox(
            height: 60,
            borderRadius: IaculaRadius.small,
          ),
        ],
      ],
    );
  }
}

/// A shimmer text-line placeholder.
class IaculaShimmerText extends StatelessWidget {
  const IaculaShimmerText({
    super.key,
    this.width,
    this.height = 14,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IaculaShimmerBox(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }
}
