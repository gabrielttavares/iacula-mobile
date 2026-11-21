import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../confession/infrastructure/services/hero_card_share_image_renderer.dart';
import '../../custom_phrases/presentation/edit_prayer_alarm_screen.dart';
import '../../more/infrastructure/app_store_review.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import '../domain/entities/prayer_detail.dart';
import '../domain/services/prayer_share_text.dart';
import 'widgets/devotional_prayer_text.dart';
import 'widgets/font_size_controls.dart';

final _prayerDetailProvider = FutureProvider.family<PrayerDetail, String>((
  ref,
  slug,
) async {
  return ref
      .watch(prayerContentRepositoryProvider)
      .loadPrayerDetail(slug: slug);
});

class PrayerCatalogDetailScreen extends ConsumerStatefulWidget {
  const PrayerCatalogDetailScreen({super.key, required this.entry});

  final PrayerCatalogEntry entry;

  @override
  ConsumerState<PrayerCatalogDetailScreen> createState() =>
      _PrayerCatalogDetailScreenState();
}

class _PrayerCatalogDetailScreenState
    extends ConsumerState<PrayerCatalogDetailScreen> {
  String _selectedLanguage = 'pt-br';

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_prayerDetailProvider(widget.entry.slug));
    final fontSize = ref.watch(prayerFontSizeProvider).valueOrNull ?? 15.0;
    final navigationTitle = _resolveNavigationTitle(detailAsync);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const SizedBox.shrink(),
            middle: Text(
              navigationTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            alwaysShowMiddle: false,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (detailAsync.valueOrNull case final detail?)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    onPressed: () => _sharePrayer(detail),
                    child: Icon(
                      CupertinoIcons.share,
                      color: context.colors.primaryButton,
                      size: 21,
                    ),
                  ),
                _PrayerAlarmButton(entry: widget.entry),
                _PrayerBookmarkButton(entry: widget.entry),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                IaculaSpacing.md,
                0,
                IaculaSpacing.md,
                IaculaSpacing.sm,
              ),
              child: Text(
                navigationTitle,
                style: CupertinoTheme.of(
                  context,
                ).textTheme.navLargeTitleTextStyle,
              ),
            ),
          ),
          ...detailAsync.when(
            loading: () => _buildLoadingContentSlivers(),
            error: (error, stackTrace) => _buildErrorContentSlivers(),
            data: (detail) =>
                _buildLoadedContentSlivers(detail: detail, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  /// Shares the prayer as an image card (for WhatsApp status and stories)
  /// plus the full text and a link to the app.
  Future<void> _sharePrayer(PrayerDetail detail) async {
    HapticFeedback.selectionClick();
    final available = detail.blocksByLanguage.keys.toList(growable: false);
    final language = _resolveSelectedLanguage(
      detail: detail,
      available: available,
    );
    final title = detail.titlesByLanguage[language] ?? widget.entry.title;
    final text = formatPrayerForSharing(
      title: title,
      blocks: detail.blocksByLanguage[language] ?? const <String>[],
      appLink: iaculaStoreUrl(defaultTargetPlatform),
    );

    final imageBytes = await ref
        .read(heroCardShareImageRendererProvider)
        .renderPng(
          context: context,
          payload: HeroCardSharePayload(text: title, labelText: 'Oração'),
        );
    final shareService = ref.read(nativeShareServiceProvider);
    if (imageBytes != null) {
      await shareService.shareTextWithImage(
        text: text,
        imageBytes: imageBytes,
        fileName: 'iacula-${widget.entry.slug}.png',
      );
      return;
    }
    await shareService.shareText(text);
  }

  String _resolveNavigationTitle(AsyncValue<PrayerDetail> detailAsync) {
    return detailAsync.when(
      data: (detail) {
        final available = detail.blocksByLanguage.keys.toList(growable: false);
        final selectedLanguage = _resolveSelectedLanguage(
          detail: detail,
          available: available,
        );
        return detail.titlesByLanguage[selectedLanguage] ?? widget.entry.title;
      },
      loading: () => widget.entry.title,
      error: (error, stackTrace) => widget.entry.title,
    );
  }

  List<Widget> _buildLoadingContentSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.all(IaculaSpacing.md),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: const [
              IaculaShimmerText(width: 200, height: 20),
              SizedBox(height: IaculaSpacing.md),
              IaculaShimmerText(),
              SizedBox(height: IaculaSpacing.xs),
              IaculaShimmerText(),
              SizedBox(height: IaculaSpacing.xs),
              IaculaShimmerText(width: 160),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildErrorContentSlivers() {
    return [
      SliverFillRemaining(
        child: IaculaErrorState(
          title: 'Erro ao carregar oracao',
          message: 'Tente novamente para abrir o conteudo.',
          onRetry: () =>
              ref.invalidate(_prayerDetailProvider(widget.entry.slug)),
        ),
      ),
    ];
  }

  List<Widget> _buildLoadedContentSlivers({
    required PrayerDetail detail,
    required double fontSize,
  }) {
    final available = detail.blocksByLanguage.keys.toList(growable: false);
    final selectedLanguage = _resolveSelectedLanguage(
      detail: detail,
      available: available,
    );

    final contentBlocks =
        detail.blocksByLanguage[selectedLanguage] ??
        const <String>['Conteúdo indisponível.'];

    final bottomPadding =
        MediaQuery.paddingOf(context).bottom + IaculaSpacing.md;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.lg,
          ),
          child: Row(
            children: [
              if (available.length > 1) ...[
                Expanded(
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: selectedLanguage,
                    children: const {
                      'pt-br': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('PT'),
                      ),
                      'la': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('LAT'),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      if (_isLanguageAvailable(value, available)) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: IaculaSpacing.md),
              ],
              const FontSizeControls(),
            ],
          ),
        ),
      ),
      SliverPadding(
        key: ValueKey<String>(selectedLanguage),
        padding: EdgeInsets.fromLTRB(
          IaculaSpacing.md,
          0,
          IaculaSpacing.md,
          bottomPadding,
        ),
        sliver: SliverToBoxAdapter(
          child: DevotionalPrayerText(
            blocks: contentBlocks,
            fontSize: fontSize,
          ),
        ),
      ),
    ];
  }

  String _resolveSelectedLanguage({
    required PrayerDetail detail,
    required List<String> available,
  }) {
    if (_isLanguageAvailable(_selectedLanguage, available)) {
      return _selectedLanguage;
    }
    if (available.contains(detail.defaultLanguage)) {
      return detail.defaultLanguage;
    }
    return available.isNotEmpty ? available.first : 'pt-br';
  }

  bool _isLanguageAvailable(String language, List<String> available) {
    return available.contains(language);
  }
}

class _PrayerAlarmButton extends StatelessWidget {
  const _PrayerAlarmButton({required this.entry});

  final PrayerCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => EditPrayerAlarmScreen(initialPrayer: entry),
          ),
        );
      },
      child: Icon(
        CupertinoIcons.bell,
        color: context.colors.primaryButton,
        size: 22,
      ),
    );
  }
}

class _PrayerBookmarkButton extends ConsumerWidget {
  const _PrayerBookmarkButton({required this.entry});

  final PrayerCatalogEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAsync = ref.watch(
      favoriteItemByPrayerSlugProvider(entry.slug),
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
              id: 'prayer:${entry.slug}',
              quoteText: entry.title,
              theme: 'Oração',
              season: '',
              savedAt: DateTime.now(),
              prayerSlug: entry.slug,
            ),
          );
        }
      },
      child: IaculaAnimatedIcon(
        icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
        color: context.colors.primaryButton,
        size: 22,
        enableHaptics: false,
      ),
    );
  }
}
