import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../pages/quote_full_text_screen.dart';
import 'hero_action_buttons.dart';

class HomeHeroCard extends ConsumerStatefulWidget {
  const HomeHeroCard({super.key, required this.quote});

  final Quote quote;

  @override
  ConsumerState<HomeHeroCard> createState() => _HomeHeroCardState();
}

class _HomeHeroCardState extends ConsumerState<HomeHeroCard> {
  bool _isTruncated = false;

  String? _resolveAssetPath(String? path) {
    if (path == null) {
      return null;
    }
    final value = path.trim();
    if (value.isEmpty) {
      return null;
    }
    return value.startsWith('/') ? value.substring(1) : value;
  }

  void _handleTruncationChanged(bool value) {
    if (!mounted) {
      return;
    }
    if (_isTruncated == value) {
      return;
    }
    setState(() {
      _isTruncated = value;
    });
  }

  void _openFullText(BuildContext context, Quote quote, String labelText) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) =>
            QuoteFullTextScreen(quote: quote, labelText: labelText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final isEscrivaPoints = quote.resolvedSource == QuoteSource.escrivaPoints;
    final imagePath = _resolveAssetPath(quote.imagePath);
    final labelText =
        quote.feastName ??
        (isEscrivaPoints
            ? quote.referenceLabel
            : quote.theme == 'personal'
            ? 'frase pessoal'
            : quote.theme) ??
        '';

    return PremiumTouchableCard(
      borderRadius: IaculaRadius.banner,
      onTap: () => _openFullText(context, quote, labelText),
      child: Container(
        key: const Key('home_hero_card'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IaculaRadius.banner),
          boxShadow: [
            BoxShadow(
              color: context.colors.separator,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 240),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(IaculaRadius.banner),
            child: Stack(
              children: [
                SizedBox(height: 240, width: double.infinity),
                Positioned.fill(
                  child: isEscrivaPoints
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1A2640),
                                const Color(0xFF101B32),
                                const Color(0xFF232346),
                              ],
                              stops: const [0.0, 0.48, 1.0],
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
                if (isEscrivaPoints)
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
                        alpha: isEscrivaPoints ? 0.30 : 0.40,
                      ),
                    ),
                  ),
                ),
                if (!isEscrivaPoints)
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
                Positioned(
                  top: 18,
                  right: 18,
                  child: HeroActionButtons(quote: quote),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: isEscrivaPoints
                        ? const EdgeInsets.fromLTRB(18, 58, 18, 28)
                        : const EdgeInsets.all(18),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: _isTruncated
                                  ? ShaderMask(
                                      key: const Key('home_hero_text_fade'),
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            context.colors.homeHeroText,
                                            context.colors.homeHeroText,
                                            context.colors.homeHeroText
                                                .withValues(alpha: 0.0),
                                          ],
                                          stops: const [0.0, 0.78, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: _AutoSizingQuoteText(
                                        text: quote.text,
                                        onTruncationChanged:
                                            _handleTruncationChanged,
                                      ),
                                    )
                                  : _AutoSizingQuoteText(
                                      text: quote.text,
                                      onTruncationChanged:
                                          _handleTruncationChanged,
                                    ),
                            ),
                          ),
                          if (_isTruncated) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Continuar lendo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.primaryButton,
                              ),
                            ),
                          ] else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                if (labelText.isNotEmpty)
                  Positioned(
                    left: 18,
                    bottom: 8,
                    child: Text(
                      labelText.toLowerCase(),
                      key: const Key('home_hero_season_label'),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: context.colors.homeHeroLabel,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoSizingQuoteText extends StatelessWidget {
  const _AutoSizingQuoteText({
    required this.text,
    required this.onTruncationChanged,
  });

  final String text;
  final ValueChanged<bool> onTruncationChanged;

  @override
  Widget build(BuildContext context) {
    const maxFontSize = 17.0;
    const minFontSize = 12.0;
    const lineHeight = 1.45;

    return LayoutBuilder(
      builder: (context, constraints) {
        var chosenSize = maxFontSize;
        var isTruncated = false;
        final maxLines = (constraints.maxHeight / (minFontSize * lineHeight))
            .floor()
            .clamp(1, 20);

        for (var size = maxFontSize; size >= minFontSize; size -= 0.5) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w600,
                color: context.colors.homeHeroText,
                height: lineHeight,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: maxLines,
          )..layout(maxWidth: constraints.maxWidth);

          if (!painter.didExceedMaxLines &&
              painter.height <= constraints.maxHeight) {
            chosenSize = size;
            break;
          }

          if (size == minFontSize) {
            chosenSize = minFontSize;
            isTruncated =
                painter.didExceedMaxLines ||
                painter.height > constraints.maxHeight;
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onTruncationChanged(isTruncated);
        });

        return Text(
          text,
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
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
