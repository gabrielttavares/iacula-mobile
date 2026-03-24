import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_prayerDetailProvider(widget.entry.slug));
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.entry.title),
        backgroundColor: context.colors.background,
        trailing: _PrayerBookmarkButton(entry: widget.entry),
      ),
      child: SafeArea(
        child: FutureBuilder(
          future: settingsAsync,
          builder: (context, settingsSnapshot) {
            final fontSize = settingsSnapshot.data?.prayerFontSize ?? 15.0;

            return detailAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.all(IaculaSpacing.md),
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
              error: (error, stackTrace) => Center(
                child: IaculaErrorState(
                  title: 'Erro ao carregar oracao',
                  message: 'Tente novamente para abrir o conteudo.',
                  onRetry: () => ref.invalidate(
                    _prayerDetailProvider(widget.entry.slug),
                  ),
                ),
              ),
              data: (detail) {
                final available = detail.blocksByLanguage.keys.toList(
                  growable: false,
                );
                final selectedLanguage =
                    _isLanguageAvailable(_selectedLanguage, available)
                    ? _selectedLanguage
                    : (available.contains(detail.defaultLanguage)
                          ? detail.defaultLanguage
                          : (available.isNotEmpty ? available.first : 'pt-br'));

                final contentBlocks =
                    detail.blocksByLanguage[selectedLanguage] ??
                    const <String>['Conteúdo indisponível.'];

                return Padding(
                  padding: const EdgeInsets.all(IaculaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: IaculaSpacing.lg),
                      Text(
                        detail.titlesByLanguage[selectedLanguage] ??
                            widget.entry.title,
                        style: context.textStyles.sectionTitle.copyWith(
                          fontSize: fontSize + 7,
                        ),
                      ),
                  const SizedBox(height: IaculaSpacing.lg),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: ListView.separated(
                        key: ValueKey<String>(selectedLanguage),
                        physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      itemCount: contentBlocks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: IaculaSpacing.md),
                      itemBuilder: (context, index) {
                        return Text(
                          contentBlocks[index],
                          style: context.textStyles.readingBody.copyWith(
                            fontSize: fontSize,
                          ),
                        );
                      },
                    ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    ),
    );
  }

  bool _isLanguageAvailable(String language, List<String> available) {
    return available.contains(language);
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
