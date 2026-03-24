import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_scroll_item_entrance.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../home/presentation/home_prayer_groups.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import 'prayer_catalog_group_screen.dart';

final _catalogProvider = FutureProvider<List<PrayerCatalogEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref
      .watch(getPrayerCatalogUseCaseProvider)
      .listAll(language: settings.language);
});

// Ordem explícita das seções conforme o PDF
const _sectionOrder = [
  'oracoes-comuns',
  'oracoes-santissima-trindade',
  'adoracao-eucaristica',
  'ao-espirito-santo',
  'oracoes-a-nossa-senhora',
  'preparacao-santa-missa',
  'acao-de-gracas-santa-missa',
  'oracoes-a-sao-jose',
  'oracoes-diversas',
  'outras-devocoes',
  'oracoes-pelos-defuntos',
];

class PrayerCollectionsScreen extends ConsumerWidget {
  const PrayerCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_catalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('Orações', style: context.textStyles.cardTitle),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              catalogAsync.when(
                data: (entries) {
                  final grouped = _groupBySection(entries);
                  return Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final group = grouped[index];

                        return IaculaScrollItemEntrance(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: IaculaSpacing.sm,
                            ),
                            child: _PrayerCategoryCard(
                                  title: group.sectionTitle,
                                  iconPath: kSectionIcons[group.sectionId],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            PrayerCatalogGroupScreen(
                                              type: HomePrayerGroupType.section,
                                              groupKey: group.sectionId,
                                              title: group.sectionTitle,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () =>
                    const Expanded(child: IaculaShimmerList(itemCount: 6)),
                error: (error, stackTrace) => IaculaErrorState(
                  title: 'Erro ao carregar oracoes',
                  message: 'Tente novamente para abrir as colecoes.',
                  onRetry: () => ref.invalidate(_catalogProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerCategoryCard extends StatelessWidget {
  const _PrayerCategoryCard({
    required this.title,
    required this.onTap,
    this.iconPath,
  });

  final String title;
  final VoidCallback onTap;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: IaculaSpacing.md,
            vertical: IaculaSpacing.md,
          ),
          child: Row(
            children: [
              if (iconPath != null) ...[
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    context.colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    iconPath!,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(child: Text(title, style: context.textStyles.cardTitle)),
              Icon(
                CupertinoIcons.chevron_right,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<_SectionGroup> _groupBySection(List<PrayerCatalogEntry> entries) {
  // Group by section_id (not section_title)
  final buckets = <String, List<PrayerCatalogEntry>>{};
  final sectionTitles = <String, String>{};

  for (final entry in entries) {
    final sectionId = entry.sectionId.isNotEmpty ? entry.sectionId : 'outras';
    buckets.putIfAbsent(sectionId, () => <PrayerCatalogEntry>[]).add(entry);
    // Store the section title for this ID
    if (entry.sectionTitle.isNotEmpty) {
      sectionTitles[sectionId] = entry.sectionTitle;
    }
  }

  // Sort according to _sectionOrder
  final sortedIds = <String>[];

  // First, add sections that are in _sectionOrder
  for (final id in _sectionOrder) {
    if (buckets.containsKey(id)) {
      sortedIds.add(id);
    }
  }

  // Then, add any remaining sections not in _sectionOrder
  for (final id in buckets.keys) {
    if (!sortedIds.contains(id)) {
      sortedIds.add(id);
    }
  }

  // Create groups in order
  final groups = sortedIds
      .map(
        (id) => _SectionGroup(
          sectionId: id,
          sectionTitle: sectionTitles[id] ?? 'Outras',
          entries: buckets[id]!,
        ),
      )
      .toList(growable: false);

  return groups;
}

final class _SectionGroup {
  const _SectionGroup({
    required this.sectionId,
    required this.sectionTitle,
    required this.entries,
  });

  final String sectionId;
  final String sectionTitle;
  final List<PrayerCatalogEntry> entries;
}
