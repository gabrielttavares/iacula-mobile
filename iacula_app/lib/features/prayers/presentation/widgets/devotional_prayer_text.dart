import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show MaterialLocalizations, SelectionArea;

import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/services/prayer_block_parser.dart';

/// Renders prayer blocks like a printed devotional: red ℣/℟ in a hanging
/// column, the people's part in a heavier weight, rubrics in red italics and
/// headings set apart.
class DevotionalPrayerText extends StatelessWidget {
  const DevotionalPrayerText({
    super.key,
    required this.blocks,
    required this.fontSize,
  });

  final List<String> blocks;
  final double fontSize;

  static const _parser = PrayerBlockParser();

  /// The reading fonts (Lora/Inter) have no ℣/℟ glyphs; name system fonts
  /// that do, so the markers never fall back to a missing-glyph box.
  static const markerFontFallback = <String>[
    'Apple Symbols',
    'Noto Sans Symbols',
    'Segoe UI Symbol',
  ];

  static TextStyle markerStyle(TextStyle base, Color red) => base.copyWith(
    color: red,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: markerFontFallback,
  );

  /// Liturgical red, readable on both light and dark backgrounds.
  static Color rubricColor(BuildContext context) =>
      CupertinoTheme.brightnessOf(context) == Brightness.dark
      ? const Color(0xFFE57373)
      : const Color(0xFFA51C24);

  @override
  Widget build(BuildContext context) {
    final parsed = _parser.parseAll(blocks);

    final children = <Widget>[];

    for (var i = 0; i < parsed.length; i++) {
      final block = parsed[i];
      if (children.isNotEmpty) {
        children.add(
          SizedBox(height: _gapBefore(block, i > 0 ? parsed[i - 1] : null)),
        );
      }
      children.add(_BlockView(block: block, fontSize: fontSize));
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    // Selection across blocks needs the Material localizations the app
    // provides; without them (isolated widget tests) render plain text.
    final hasMaterialLocalizations =
        Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) !=
        null;
    return hasMaterialLocalizations ? SelectionArea(child: column) : column;
  }

  /// ℣ and its ℟ sit close together, like a pair; headings get air above.
  double _gapBefore(PrayerBlock block, PrayerBlock? previous) {
    if (block.kind == PrayerBlockKind.heading) return fontSize * 1.6;
    if (previous == null) return fontSize * 0.9;
    if (block.kind == PrayerBlockKind.response &&
        previous.kind == PrayerBlockKind.versicle) {
      return fontSize * 0.25;
    }
    if (previous.kind == PrayerBlockKind.heading) return fontSize * 0.5;
    if (_isLitanyLine(block) && _isLitanyLine(previous)) return fontSize * 0.3;
    return fontSize * 0.9;
  }

  bool _isLitanyLine(PrayerBlock block) =>
      block.kind == PrayerBlockKind.text && block.hasResponse;
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.fontSize});

  final PrayerBlock block;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final red = DevotionalPrayerText.rubricColor(context);
    final body = context.textStyles.readingBody.copyWith(fontSize: fontSize);

    switch (block.kind) {
      case PrayerBlockKind.heading:
        return Text(
          block.plainText,
          style: context.textStyles.cardTitle.copyWith(
            fontSize: fontSize + 1,
            color: context.colors.title,
          ),
        );
      case PrayerBlockKind.rubric:
        return Text(block.plainText, style: _rubricStyle(body, red));
      case PrayerBlockKind.versicle:
      case PrayerBlockKind.response:
        final isResponse = block.kind == PrayerBlockKind.response;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: fontSize * 1.5,
              child: Text(
                isResponse ? '℟' : '℣',
                style: DevotionalPrayerText.markerStyle(body, red),
              ),
            ),
            Expanded(
              child: Text.rich(
                _spans(context, isResponse ? _responseStyle(body) : body, red),
              ),
            ),
          ],
        );
      case PrayerBlockKind.text:
        return Text.rich(_spans(context, body, red));
    }
  }

  TextSpan _spans(BuildContext context, TextStyle base, Color red) {
    return TextSpan(
      style: base,
      children: [for (final span in block.spans) ..._span(span, base, red)],
    );
  }

  List<InlineSpan> _span(PrayerSpan span, TextStyle base, Color red) {
    switch (span.kind) {
      case PrayerSpanKind.text:
        return [TextSpan(text: span.text)];
      case PrayerSpanKind.cue:
        return [
          TextSpan(
            text: span.text,
            style: base.copyWith(fontStyle: FontStyle.italic),
          ),
        ];
      case PrayerSpanKind.rubric:
        return [TextSpan(text: span.text, style: _rubricStyle(base, red))];
      case PrayerSpanKind.response:
        return [
          TextSpan(
            text: '℟ ',
            style: DevotionalPrayerText.markerStyle(base, red),
          ),
          TextSpan(text: span.text, style: _responseStyle(base)),
        ];
    }
  }

  TextStyle _responseStyle(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w600);

  TextStyle _rubricStyle(TextStyle base, Color red) => base.copyWith(
    color: red,
    fontStyle: FontStyle.italic,
    fontSize: fontSize * 0.86,
  );
}
