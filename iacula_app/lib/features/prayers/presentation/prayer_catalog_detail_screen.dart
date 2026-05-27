import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/presentation/edit_prayer_alarm_screen.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import '../domain/entities/prayer_detail.dart';
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
  Future<double>? _fontSizeFuture;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  void _loadFontSize() {
    _fontSizeFuture = ref
        .read(getSettingsUseCaseProvider)
        .call()
        .then((settings) => settings.prayerFontSize);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_prayerDetailProvider(widget.entry.slug));

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: FutureBuilder<double>(
        future: _fontSizeFuture,
        builder: (context, fontSizeSnapshot) {
          final fontSize = fontSizeSnapshot.data ?? 15.0;
          final navigationTitle = _resolveNavigationTitle(detailAsync);

          return CustomScrollView(
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
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navLargeTitleTextStyle,
                  ),
                ),
              ),
              ...detailAsync.when(
                loading: () => _buildLoadingContentSlivers(),
                error: (error, stackTrace) => _buildErrorContentSlivers(),
                data: (detail) => _buildLoadedContentSlivers(
                  detail: detail,
                  fontSize: fontSize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _resolveNavigationTitle(AsyncValue<PrayerDetail> detailAsync) {
    return detailAsync.when(
      data: (detail) {
        final available =
            detail.blocksByLanguage.keys.toList(growable: false);
        final selectedLanguage = _resolveSelectedLanguage(
          detail: detail,
          available: available,
        );
        return detail.titlesByLanguage[selectedLanguage] ??
            widget.entry.title;
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
          onRetry: () => ref.invalidate(
            _prayerDetailProvider(widget.entry.slug),
          ),
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
          child: SelectableText.rich(
            TextSpan(
              children: _buildPrayerTextSpans(
                blocks: contentBlocks,
                fontSize: fontSize,
              ),
            ),
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

  List<InlineSpan> _buildPrayerTextSpans({
    required List<String> blocks,
    required double fontSize,
  }) {
    final spans = <InlineSpan>[];
    for (var index = 0; index < blocks.length; index++) {
      if (index > 0) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      final block = blocks[index];

      if (_isItalicBlock(block)) {
        spans.add(TextSpan(
          text: block.substring(1, block.length - 1),
          style: context.textStyles.readingBody.copyWith(
            fontSize: fontSize,
            fontStyle: FontStyle.italic,
            color: context.colors.textSecondary,
          ),
        ));
      } else if (block.startsWith('℣ ') || block.startsWith('℟ ')) {
        final marker = block.substring(0, 1);
        final text = block.substring(2);
        spans.add(TextSpan(
          children: [
            TextSpan(
              text: '$marker. ',
              style: context.textStyles.readingBody.copyWith(
                fontSize: fontSize,
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: text,
              style: context.textStyles.readingBody.copyWith(
                fontSize: fontSize,
              ),
            ),
          ],
        ));
      } else {
        spans.add(TextSpan(
          text: block,
          style: context.textStyles.readingBody.copyWith(fontSize: fontSize),
        ));
      }
    }
    return spans;
  }

  bool _isLanguageAvailable(String language, List<String> available) {
    return available.contains(language);
  }

  bool _isItalicBlock(String block) {
    return block.startsWith('*') &&
        block.endsWith('*') &&
        block.length > 2;
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
    final favoriteAsync = ref.watch(favoriteItemByPrayerSlugProvider(entry.slug));
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
