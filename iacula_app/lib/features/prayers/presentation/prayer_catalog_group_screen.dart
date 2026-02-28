import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../home/presentation/home_prayer_groups.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import 'prayer_catalog_detail_screen.dart';

final _groupEntriesProvider = FutureProvider.family
    .autoDispose<List<PrayerCatalogEntry>, PrayerCatalogGroupRequest>((
      ref,
      request,
    ) async {
      final settings = await ref.watch(getSettingsUseCaseProvider).call();
      final useCase = ref.watch(getPrayerCatalogUseCaseProvider);
      return switch (request.type) {
        HomePrayerGroupType.theme => useCase.byTheme(
          language: settings.language,
          theme: request.groupKey,
        ),
        HomePrayerGroupType.saint => useCase.bySaint(
          language: settings.language,
          saint: request.groupKey,
        ),
      };
    });

final class PrayerCatalogGroupRequest {
  const PrayerCatalogGroupRequest({required this.type, required this.groupKey});

  final HomePrayerGroupType type;
  final String groupKey;

  @override
  bool operator ==(Object other) {
    return other is PrayerCatalogGroupRequest &&
        other.type == type &&
        other.groupKey == groupKey;
  }

  @override
  int get hashCode => Object.hash(type, groupKey);
}

class PrayerCatalogGroupScreen extends ConsumerWidget {
  const PrayerCatalogGroupScreen({
    super.key,
    required this.type,
    required this.groupKey,
    required this.title,
  });

  final HomePrayerGroupType type;
  final String groupKey;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(
      _groupEntriesProvider(
        PrayerCatalogGroupRequest(type: type, groupKey: groupKey),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        backgroundColor: IaculaColors.background,
      ),
      child: SafeArea(
        child: entriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma oração encontrada',
                  style: IaculaText.secondary,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              itemCount: entries.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: IaculaSpacing.sm),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _PrayerItemCard(entry: entry);
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Não foi possível carregar as orações',
              style: IaculaText.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerItemCard extends StatelessWidget {
  const _PrayerItemCard({required this.entry});

  final PrayerCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => PrayerCatalogDetailScreen(entry: entry),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(IaculaSpacing.md),
        decoration: BoxDecoration(
          color: IaculaColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: IaculaColors.separator),
        ),
        child: Row(
          children: [
            Expanded(child: Text(entry.title, style: IaculaText.cardTitle)),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: IaculaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
