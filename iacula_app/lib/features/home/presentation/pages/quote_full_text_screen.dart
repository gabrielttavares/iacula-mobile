import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

import '../../../../core/theme/cupertino_tokens.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../widgets/hero_action_buttons.dart';

class QuoteFullTextScreen extends StatelessWidget {
  const QuoteFullTextScreen({
    super.key,
    required this.quote,
    required this.labelText,
  });

  final Quote quote;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    final isEscrivaPoints = quote.resolvedSource == QuoteSource.escrivaPoints;

    return CupertinoPageScaffold(
      key: const Key('quote_full_text_screen'),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withValues(
          alpha: 0.0,
        ),
        border: null,
        middle: Text(labelText.toLowerCase()),
        trailing: HeroActionButtons(quote: quote),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.background,
          gradient: isEscrivaPoints
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A2640),
                    Color(0xFF101B32),
                    Color(0xFF232346),
                  ],
                  stops: [0.0, 0.48, 1.0],
                )
              : null,
        ),
        child: Stack(
          children: [
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
                    alpha: isEscrivaPoints ? 0.30 : 0.0,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
                children: [
                  Text(
                    quote.text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.55,
                      color: isEscrivaPoints
                          ? context.colors.homeHeroText
                          : context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    labelText.toLowerCase(),
                    key: const Key('quote_full_text_label'),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.8,
                      color: isEscrivaPoints
                          ? context.colors.homeHeroLabel
                          : context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
