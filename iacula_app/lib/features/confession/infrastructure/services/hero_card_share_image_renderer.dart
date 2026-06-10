import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/cupertino_tokens.dart';

final class HeroCardSharePayload {
  const HeroCardSharePayload({
    required this.text,
    required this.labelText,
    this.imagePath,
    this.isEscrivaPoints = false,
  });

  final String text;
  final String labelText;
  final String? imagePath;
  final bool isEscrivaPoints;
}

final class HeroCardShareImageRenderer {
  const HeroCardShareImageRenderer();

  static const Size _cardSize = Size(390, 240);
  static const double _pixelRatio = 3;

  Future<Uint8List?> renderPng({
    required BuildContext context,
    required HeroCardSharePayload payload,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);

    final repaintKey = GlobalKey();
    final mediaQuery = MediaQuery.maybeOf(context);

    final entry = OverlayEntry(
      builder: (overlayContext) {
        final child = SizedBox(
          width: _cardSize.width,
          height: _cardSize.height,
          child: RepaintBoundary(
            key: repaintKey,
            child: HeroCardSharePreview(payload: payload),
          ),
        );

        return Positioned(
          left: -10000,
          top: -10000,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: mediaQuery == null ? child : MediaQuery(data: mediaQuery, child: child),
          ),
        );
      },
    );

    overlay.insert(entry);

    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 16));

      final boundary =
          repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }
}

final class HeroCardSharePreview extends StatelessWidget {
  const HeroCardSharePreview({super.key, required this.payload});

  final HeroCardSharePayload payload;

  String? _resolveAssetPath(String? path) {
    if (path == null) return null;
    final value = path.trim();
    if (value.isEmpty) return null;
    return value.startsWith('/') ? value.substring(1) : value;
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _resolveAssetPath(payload.imagePath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(IaculaRadius.banner),
      child: Stack(
        children: [
          const SizedBox(height: 240, width: double.infinity),
          Positioned.fill(
            child: payload.isEscrivaPoints
                ? const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A2640),
                          Color(0xFF101B32),
                          Color(0xFF232346),
                        ],
                        stops: [0.0, 0.48, 1.0],
                      ),
                    ),
                  )
                : imagePath != null
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) =>
                        DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.homeHeroFallback,
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.homeHeroFallback,
                    ),
                  ),
          ),
          if (payload.isEscrivaPoints)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.45, -0.5),
                    radius: 1.05,
                    colors: [
                      Colors.white.withValues(alpha: 0.11),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: payload.isEscrivaPoints ? 0.22 : 0.34,
                ),
              ),
            ),
          ),
          if (!payload.isEscrivaPoints)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.homeHeroTop,
                      context.colors.homeHeroBottom,
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _AutoSizingQuoteText(text: payload.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 8,
            child: Text(
              payload.labelText.toLowerCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                color: context.colors.homeHeroLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoSizingQuoteText extends StatelessWidget {
  const _AutoSizingQuoteText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const maxFontSize = 17.0;
    const minFontSize = 12.0;
    const lineHeight = 1.45;

    return LayoutBuilder(
      builder: (context, constraints) {
        var chosenSize = maxFontSize;
        for (var size = maxFontSize; size >= minFontSize; size -= 0.5) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: GoogleFonts.lora(
                fontSize: size,
                fontWeight: FontWeight.w600,
                color: context.colors.homeHeroText,
                height: lineHeight,
              ),
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          if (painter.height <= constraints.maxHeight) {
            chosenSize = size;
            break;
          }
        }

        return Text(
          text,
          textAlign: TextAlign.left,
          style: GoogleFonts.lora(
            fontSize: chosenSize,
            fontWeight: FontWeight.w600,
            color: context.colors.homeHeroText,
            height: lineHeight,
          ),
        );
      },
    );
  }
}
