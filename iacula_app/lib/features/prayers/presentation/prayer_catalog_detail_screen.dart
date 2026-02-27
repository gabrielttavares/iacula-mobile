import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import '../domain/entities/prayer_detail.dart';

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

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.entry.title),
        backgroundColor: IaculaColors.background,
      ),
      child: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => const Center(
            child: Text('Erro ao carregar oração', style: IaculaText.secondary),
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
                  if (available.length > 1) ...[
                    CupertinoSlidingSegmentedControl<String>(
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
                    const SizedBox(height: IaculaSpacing.lg),
                  ],
                  Text(
                    detail.titlesByLanguage[selectedLanguage] ??
                        widget.entry.title,
                    style: IaculaText.sectionTitle,
                  ),
                  const SizedBox(height: IaculaSpacing.lg),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: contentBlocks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: IaculaSpacing.md),
                      itemBuilder: (context, index) {
                        return Text(
                          contentBlocks[index],
                          style: IaculaText.secondary.copyWith(
                            color: IaculaColors.textPrimary,
                            height: 1.6,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
