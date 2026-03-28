import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:google_fonts/google_fonts.dart';

import '../notifications/domain/entities/last_delivered_card.dart';

/// A headless widget that replicates the [HomeHeroCard] visual for
/// off-screen rendering via `home_widget`'s `renderFlutterWidget`.
///
/// Does NOT use Riverpod — all data is passed via constructor.
/// Does NOT include the bookmark button (not interactive on widgets).
class WidgetQuoteCard extends StatelessWidget {
  const WidgetQuoteCard({
    super.key,
    required this.card,
    required this.size,
    required this.showLabel,
    required this.fontSize,
  });

  final LastDeliveredCard card;
  final Size size;
  final bool showLabel;
  final double fontSize;

  // Matches HomeHeroCard colors (dark mode — widget always renders dark)
  static const _heroText = Color(0xFFFFFFFF);
  static const _heroLabel = Color(0x47FFFFFF);
  static const _heroTop = Color(0x40000000);
  static const _heroBottom = Color(0x99000000);
  static const _heroFallback = Color(0xFF1C1C1E);
  bool get _isEscrivaPoints => card.source == 'escrivaPoints';

  String get _labelText {
    final feast = card.feastName?.trim();
    if (feast != null && feast.isNotEmpty) {
      return feast;
    }
    if (_isEscrivaPoints) {
      return card.referenceLabel?.trim() ?? '';
    }
    if (card.theme == 'personal') {
      return 'frase pessoal';
    }
    return '';
  }

  String? _resolveAssetPath(String? path) {
    if (path == null) return null;
    final value = path.trim();
    if (value.isEmpty) return null;
    return value.startsWith('/') ? value.substring(1) : value;
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _resolveAssetPath(card.imagePath);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: Stack(
          children: [
            // Background layer
            Positioned.fill(
              child: _isEscrivaPoints
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
                          errorBuilder: (_, __, ___) => const DecoratedBox(
                            decoration: BoxDecoration(color: _heroFallback),
                          ),
                        )
                      : const DecoratedBox(
                          decoration: BoxDecoration(color: _heroFallback),
                        ),
            ),

            // Escriva radial overlay
            if (_isEscrivaPoints)
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

            // Dark overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: _isEscrivaPoints ? 0.22 : 0.34,
                  ),
                ),
              ),
            ),

            // Gradient overlay (non-Escriva)
            if (!_isEscrivaPoints)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_heroTop, _heroBottom],
                    ),
                  ),
                ),
              ),

            // Quote text — centered
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    card.quoteText,
                    textAlign: TextAlign.center,
                    maxLines: size.height > 200 ? 12 : 6,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: _heroText,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),

            // Feast / reference / personal label — bottom left (no liturgical season)
            if (showLabel && _labelText.isNotEmpty)
              Positioned(
                left: 18,
                bottom: 8,
                child: Text(
                  _labelText.toLowerCase(),
                  style: GoogleFonts.lora(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: _heroLabel,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
