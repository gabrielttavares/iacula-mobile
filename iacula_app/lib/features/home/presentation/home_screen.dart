import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';

import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/domain/entities/auth_user.dart';
import '../../liturgia_diaria/presentation/liturgia_screen.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../search/presentation/search_screen.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../doctrina/presentation/doctrine_collections_screen.dart';
import '../../quotes/domain/entities/quote.dart';
import 'widgets/home_action_grid.dart';
import 'widgets/home_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _showEmBreveDialog(BuildContext context, String title) {
    return IaculaModal.showAlert(
      context: context,
      title: title,
      message: 'Em breve',
      actionLabel: 'Fechar',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(_homeQuoteProvider);
    final isFallback =
        ref.watch(_liturgicalFallbackProvider).valueOrNull ?? false;

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: quoteAsync.when(
          data: (quote) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _HomeHeader(),
                        const SizedBox(height: IaculaSpacing.lg),
                        HomeHeroCard(
                          quote: quote,
                          isFallback: isFallback,
                          onOpenPremium: () => PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          ),
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        HomeActionGrid(
                          onOpenPrayers: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                          onOpenLiturgy: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const LiturgiaScreen(),
                              ),
                            );
                          },
                          onOpenRosary: () =>
                              _showEmBreveDialog(context, 'Rosário 📿'),
                          onOpenNovenas: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                          onOpenDoctrina: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) =>
                                    const DoctrineCollectionsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Sugestão do Dia'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _DailyPrayerList(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Orações temáticas'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _ThematicPrayerRail(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Orações de Santos'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _SaintPrayerList(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stack) =>
              Center(child: Text('Erro: $error', style: IaculaText.secondary)),
          loading: () => const Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final localName = ref.watch(localDisplayNameProvider).valueOrNull;
    final greeting =
        authState.whenData((user) {
          final name = user?.displayName ?? localName;
          final isFemale = user?.gender == Gender.female;
          final welcome = isFemale ? 'Bem vinda' : 'Bem vindo';
          return name != null && name.isNotEmpty
              ? '$welcome, $name!'
              : '$welcome!';
        }).value ??
        'Bem vindo!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Iacula', style: IaculaText.cardTitle),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.bell,
                    color: IaculaColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.search,
                    color: IaculaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: IaculaSpacing.sm),
        IaculaLargeTitle(greeting),
      ],
    );
  }
}

class _DailyPrayerList extends ConsumerWidget {
  const _DailyPrayerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = ref.watch(_suggestionProvider);

    return suggestion.when(
      data: (entry) {
        if (entry == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => PrayerCatalogDetailScreen(entry: entry),
            ),
          ),
          child: IaculaSoftCard(
            radius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: _PrayerListItem(
              title: entry.title,
              subtitle: entry.content.length > 60
                  ? '${entry.content.substring(0, 60)}...'
                  : entry.content,
              avatarLabel: entry.title[0],
            ),
          ),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ThematicPrayerRail extends ConsumerWidget {
  const _ThematicPrayerRail();

  static const _themeLabels = {
    'familia': 'Família',
    'trabalho': 'Trabalho',
    'mariano': 'Mariano',
    'penitencia': 'Penitência',
    'protecao': 'Proteção',
    'esperanca': 'Esperança',
    'espirito-santo': 'Espírito Santo',
    'eucaristia': 'Eucaristia',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_thematicProvider);
    final width = MediaQuery.of(context).size.width * 0.7;

    return catalogAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: IaculaSpacing.sm),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final themeLabel =
                  entry.themes
                      .map((t) => _themeLabels[t])
                      .where((l) => l != null)
                      .firstOrNull ??
                  entry.themes.firstOrNull ??
                  '';
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => PrayerCatalogDetailScreen(entry: entry),
                  ),
                ),
                child: SizedBox(
                  width: width,
                  child: IaculaSoftCard(
                    radius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(entry.title, style: IaculaText.cardTitle),
                        const SizedBox(height: 6),
                        Text(themeLabel, style: IaculaText.secondary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SaintPrayerList extends ConsumerWidget {
  const _SaintPrayerList();

  static const _saintLabels = {
    'virgem-maria': 'Virgem Maria',
    'sao-jose': 'São José',
    'sao-tomas-de-aquino': 'São Tomás de Aquino',
    'sao-josemaria': 'São Josemaria',
    'anjos': 'Anjos',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_saintProvider);

    return catalogAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => PrayerCatalogDetailScreen(entry: entry),
                    ),
                  ),
                  child: IaculaSoftCard(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: _PrayerListItem(
                      title: entry.title,
                      subtitle: entry.saints
                          .map((s) => _saintLabels[s] ?? s)
                          .join(', '),
                      avatarLabel: entry.title.isNotEmpty
                          ? entry.title.substring(0, 2).toUpperCase()
                          : '',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PrayerListItem extends StatelessWidget {
  const _PrayerListItem({
    required this.title,
    required this.subtitle,
    required this.avatarLabel,
  });

  final String title;
  final String subtitle;
  final String avatarLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE9E9ED),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            avatarLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: IaculaColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: IaculaText.cardTitle),
              const SizedBox(height: 2),
              Text(subtitle, style: IaculaText.secondary),
            ],
          ),
        ),
        const Icon(
          CupertinoIcons.bookmark,
          size: 18,
          color: IaculaColors.textSecondary,
        ),
      ],
    );
  }
}

final _suggestionProvider = FutureProvider<PrayerCatalogEntry?>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref
      .watch(getPrayerCatalogUseCaseProvider)
      .suggestionOfDay(language: settings.language, date: DateTime.now());
});

final _thematicProvider = FutureProvider<List<PrayerCatalogEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final catalog = await ref
      .watch(getPrayerCatalogUseCaseProvider)
      .listAll(language: settings.language);
  return catalog.where((e) => e.themes.isNotEmpty).toList(growable: false);
});

final _saintProvider = FutureProvider<List<PrayerCatalogEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final catalog = await ref
      .watch(getPrayerCatalogUseCaseProvider)
      .listAll(language: settings.language);
  return catalog.where((e) => e.saints.isNotEmpty).toList(growable: false);
});

final _liturgicalFallbackProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(liturgicalSeasonServiceProvider);
  final context = await service.getCurrentContext();
  return context.isFallback;
});

final _homeQuoteProvider = FutureProvider<Quote>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final lastDeliveredCardRepo = ref.watch(lastDeliveredCardRepositoryProvider);
  final lastDeliveredCard = await lastDeliveredCardRepo.load();

  if (lastDeliveredCard != null) {
    return lastDeliveredCard.toQuote();
  }

  final quote = await ref
      .watch(getNextQuoteUseCaseProvider)
      .call(language: settings.language);
  await lastDeliveredCardRepo.save(
    LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now()),
  );
  return quote;
});
