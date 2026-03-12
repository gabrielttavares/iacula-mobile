import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;

import '../../theme/cupertino_tokens.dart';

class BiblicalReadingText extends StatelessWidget {
  const BiblicalReadingText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.selectable = false,
    this.style,
  });

  final String text;
  final TextAlign textAlign;
  final bool selectable;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Matches digits that are not preceded by a letter, 
    // to distinguish verse numbers from normal text as best as possible.
    final RegExp regex = RegExp(r'(?<![a-zA-Z])(\d+)');
    final matches = regex.allMatches(text);

    final effectiveStyle = style ?? context.textStyles.readingBody;

    if (matches.isEmpty) {
      if (selectable) {
        return SelectableText(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
        );
      }
      return Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
      );
    }

    final spans = <InlineSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0, top: 4.0, left: 1.0),
            child: Text(
              match.group(1)!,
              style: context.textStyles.secondary.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.colors.primaryButton,
              ),
            ),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    final span = TextSpan(
      style: effectiveStyle,
      children: spans,
    );

    if (selectable) {
      return SelectableText.rich(
        span,
        textAlign: textAlign,
      );
    }

    return RichText(
      textAlign: textAlign,
      text: span,
    );
  }
}
