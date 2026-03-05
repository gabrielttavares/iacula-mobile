import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;

import '../../../../core/theme/cupertino_tokens.dart';
import '../../data/models/reading_point_model.dart';

class ReadingParagraph extends StatelessWidget {
  const ReadingParagraph({
    super.key,
    required this.point,
    required this.fontSize,
  });

  final ReadingPointModel point;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (point.number != null || (point.title?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _headerLabel(),
              style: context.textStyles.cardTitle.copyWith(
                fontSize: fontSize + 1,
              ),
            ),
          ),
        for (var i = 0; i < point.paragraphs.length; i++) ...[
          SelectableText(
            point.paragraphs[i],
            style: context.textStyles.secondary.copyWith(
              color: context.colors.textPrimary,
              height: 1.6,
              fontSize: fontSize,
            ),
          ),
          if (i != point.paragraphs.length - 1)
            const SizedBox(height: IaculaSpacing.sm),
        ],
      ],
    );
  }

  String _headerLabel() {
    final number = point.number;
    final title = point.title;

    if (number != null && title != null && title.isNotEmpty) {
      return '$number. $title';
    }
    if (number != null) {
      return '$number.';
    }
    return title ?? '';
  }
}
