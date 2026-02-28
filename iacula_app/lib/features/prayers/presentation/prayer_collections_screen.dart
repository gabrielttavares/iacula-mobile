import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../doctrina/presentation/doctrine_collections_screen.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import 'prayer_catalog_detail_screen.dart';
import 'prayer_screen.dart';

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
  'formulas-doutrina-catolica',
  'homilia-rumo-santidade',
];

// Seções que fazem parte de "Recursos Adicionais"
const _recursosAdicionaisSections = [
  'formulas-doutrina-catolica',
  'homilia-rumo-santidade',
];

class PrayerCollectionsScreen extends ConsumerWidget {
  const PrayerCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_catalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IaculaLargeTitle('Orações'),
              const SizedBox(height: IaculaSpacing.lg),
              _PrayerCategoryCard(
                title: 'Angelus / Regina Caeli',
                icon: CupertinoIcons.bell,
                onTap: () async {
                  final settings = await ref
                      .read(getSettingsUseCaseProvider)
                      .call();
                  final prayer = await ref
                      .read(getPrayerUseCaseProvider)
                      .call(language: settings.language);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => PrayerScreen(prayer: prayer),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: IaculaSpacing.sm),
              _PrayerCategoryCard(
                title: 'Doutrina Católica',
                icon: CupertinoIcons.lightbulb,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const DoctrineCollectionsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: IaculaSpacing.lg),
              catalogAsync.when(
                data: (entries) {
                  final grouped = _groupBySection(entries);
                  return Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final group = grouped[index];
                        final isFirstRecurso = group.sectionId ==
                            _recursosAdicionaisSections.first;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: IaculaSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isFirstRecurso) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: IaculaSpacing.md,
                                  ),
                                  child: Text(
                                    'Recursos Adicionais',
                                    style: IaculaText.sectionTitle.copyWith(
                                      fontSize: 20,
                                      color: IaculaColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: IaculaSpacing.sm),
                              ],
                              Text(
                                group.sectionTitle,
                                style: IaculaText.secondary.copyWith(
                                  color: IaculaColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: IaculaSpacing.sm),
                              ...group.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: IaculaSpacing.sm,
                                  ),
                                  child: _PrayerCategoryCard(
                                    title: entry.title,
                                    icon: CupertinoIcons.book,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (_) =>
                                              PrayerCatalogDetailScreen(
                                                entry: entry,
                                              ),
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
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (_, __) => const Text(
                  'Erro ao carregar orações',
                  style: IaculaText.secondary,
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
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: IaculaColors.primaryButton),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: IaculaText.cardTitle)),
            const Icon(
              CupertinoIcons.chevron_right,
              color: IaculaColors.textSecondary,
            ),
          ],
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
      .map((id) => _SectionGroup(
            sectionId: id,
            sectionTitle: sectionTitles[id] ?? 'Outras',
            entries: buckets[id]!,
          ))
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
