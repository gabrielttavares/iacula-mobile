import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../domain/entities/notification_history_entry.dart';

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({
    super.key,
    required this.quoteText,
    required this.theme,
    required this.season,
    this.imagePath,
    this.feastName,
    this.source,
    this.referenceLabel,
    this.deliveredAt,
  });

  final String quoteText;
  final String theme;
  final String season;
  final String? imagePath;
  final String? feastName;
  final String? source;
  final String? referenceLabel;
  final DateTime? deliveredAt;

  factory NotificationDetailScreen.fromHistoryEntry(
    NotificationHistoryEntry entry,
  ) {
    return NotificationDetailScreen(
      quoteText: entry.quoteText,
      theme: entry.theme,
      season: entry.season,
      imagePath: entry.imagePath,
      feastName: entry.feastName,
      source: entry.source,
      referenceLabel: entry.referenceLabel,
      deliveredAt: entry.deliveredAt,
    );
  }

  static const _seasonLabels = <String, String>{
    'ordinary': 'tempo comum',
    'advent': 'tempo do advento',
    'lent': 'tempo da quaresma',
    'easter': 'tempo pascal',
    'christmas': 'tempo do natal',
  };

  bool get _isEscrivaPoints => source == 'escrivaPoints';

  String get _labelText {
    if (feastName != null) return feastName!;
    if (_isEscrivaPoints) return referenceLabel ?? '';
    if (theme == 'personal') return 'frase pessoal';
    return _seasonLabels[season] ?? '';
  }

  String? _resolveAssetPath(String? path) {
    if (path == null) return null;
    final value = path.trim();
    if (value.isEmpty) return null;
    return value.startsWith('/') ? value.substring(1) : value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedImage = _resolveAssetPath(imagePath);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailShareButton(
              quoteText: quoteText,
              labelText: _labelText,
              imagePath: imagePath,
              isEscrivaPoints: _isEscrivaPoints,
            ),
            const SizedBox(width: 8),
            _DetailBookmarkButton(
              quoteText: quoteText,
              theme: theme,
              season: season,
              imagePath: imagePath,
              feastName: feastName,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _isEscrivaPoints
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
                : resolvedImage != null
                    ? Image.asset(
                        resolvedImage,
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
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: _isEscrivaPoints ? 0.30 : 0.40,
                ),
              ),
            ),
          ),
          if (!_isEscrivaPoints)
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          quoteText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: context.colors.homeHeroText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_labelText.isNotEmpty)
                    Text(
                      _labelText.toLowerCase(),
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.8,
                        color: context.colors.homeHeroLabel,
                      ),
                    ),
                  if (deliveredAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(deliveredAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.homeHeroLabel.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailShareButton extends ConsumerWidget {
  const _DetailShareButton({
    required this.quoteText,
    required this.labelText,
    required this.imagePath,
    required this.isEscrivaPoints,
  });

  final String quoteText;
  final String labelText;
  final String? imagePath;
  final bool isEscrivaPoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () async {
        HapticFeedback.selectionClick();

        final renderer = ref.read(heroCardShareImageRendererProvider);
        final imageBytes = await renderer.renderPng(
          context: context,
          payload: HeroCardSharePayload(
            text: quoteText,
            labelText: labelText,
            imagePath: imagePath,
            isEscrivaPoints: isEscrivaPoints,
          ),
        );

        final shareService = ref.read(nativeShareServiceProvider);
        final shareText = '$quoteText\n\n- Iacula';
        if (imageBytes != null) {
          await shareService.shareTextWithImage(
            text: shareText,
            imageBytes: imageBytes,
            fileName: 'iacula-hero-card.png',
          );
          return;
        }
        await shareService.shareText(shareText);
      },
      child: Icon(
        CupertinoIcons.share,
        color: CupertinoColors.white,
        size: 20,
      ),
    );
  }
}

class _DetailBookmarkButton extends ConsumerWidget {
  const _DetailBookmarkButton({
    required this.quoteText,
    required this.theme,
    required this.season,
    this.imagePath,
    this.feastName,
  });

  final String quoteText;
  final String theme;
  final String season;
  final String? imagePath;
  final String? feastName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAsync = ref.watch(
      favoriteItemByQuoteTextProvider(quoteText),
    );
    final isSaved = favoriteAsync.valueOrNull != null;
    final savedItem = favoriteAsync.valueOrNull;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () async {
        HapticFeedback.selectionClick();
        final repo = ref.read(favoriteRepositoryProvider);
        if (savedItem != null) {
          await repo.remove(savedItem.id);
        } else {
          await repo.save(
            FavoriteItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              quoteText: quoteText,
              theme: theme,
              season: season,
              savedAt: DateTime.now(),
              imagePath: imagePath,
              feastName: feastName,
            ),
          );
        }
      },
      child: IaculaAnimatedIcon(
        icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
        color: CupertinoColors.white,
        size: 20,
        enableHaptics: false,
      ),
    );
  }
}
