import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';

import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_stagger_entrance.dart';
import '../../../core/presentation/widgets/image_background_card.dart';
import '../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/domain/entities/auth_user.dart';
import '../../liturgia_diaria/presentation/liturgia_screen.dart';
import '../../custom_phrases/presentation/custom_phrases_screen.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import '../../prayers/presentation/prayer_catalog_detail_screen.dart';
import '../../prayers/presentation/prayer_catalog_group_screen.dart';
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../prayer_intentions/presentation/prayer_intentions_screen.dart';
import '../../examination/presentation/examination_flow_screen.dart';
import '../../quotes/domain/entities/quote.dart';
import 'hero_reflection_sheet.dart';
import 'home_prayer_groups.dart';
import 'widgets/home_action_grid.dart';
import 'widgets/home_hero_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isFallback =
        ref.watch(_liturgicalFallbackProvider).valueOrNull ?? false;

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

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: context.colors.background,
                border: null,
                middle: Text('Iacula', style: context.textStyles.cardTitle),
                largeTitle: Text(greeting),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        CupertinoIcons.bell,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        CupertinoIcons.search,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  ref.invalidate(_homeQuoteProvider);
                  ref.invalidate(_suggestionProvider);
                  ref.invalidate(_homeThematicGroupsProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  28 + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    IaculaStaggerEntrance(
                      children: [
                        _HomeHeroSection(
                          isFallback: isFallback,
                          onHeroTap: (quote) =>
                              HeroReflectionSheet.show(context, quote: quote),
                        ),
                        const SizedBox(height: IaculaSpacing.sm),
                        _CustomPhrasesHomeCard(
                          onTap: () {
                            final isPremium =
                                ref
                                    .read(premiumStatusProvider)
                                    .valueOrNull
                                    ?.isPremium ??
                                false;
                            if (!isPremium) {
                              PremiumGate.showModal(
                                context,
                                feature: PremiumFeature.meditation,
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const CustomPhrasesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        HomeActionGrid(
                          onOpenPrayers: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                          onOpenLiturgy: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const LiturgiaScreen(),
                              ),
                            );
                          },
                          onOpenIntentions: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerIntentionsScreen(),
                              ),
                            );
                          },
                          onOpenExamination: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const ExaminationFlowScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Ênfase do Dia'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _DailyPrayerList(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const _FeatureRail(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Orações Temáticas'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _ThematicPrayerList(),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomPhrasesHomeCard extends StatelessWidget {
  const _CustomPhrasesHomeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: EdgeInsets.zero,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(
              CupertinoIcons.quote_bubble,
              color: context.colors.primaryButton,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Frases Personalizadas',
                style: context.textStyles.cardTitle.copyWith(fontSize: 16),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroSection extends ConsumerWidget {
  const _HomeHeroSection({required this.isFallback, required this.onHeroTap});

  final bool isFallback;
  final ValueChanged<Quote> onHeroTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(_homeQuoteProvider);
    return quoteAsync.when(
      data: (quote) =>
          HomeHeroCard(quote: quote, isFallback: isFallback, onTap: onHeroTap),
      loading: () => const SizedBox(
        height: 240,
        child: IaculaShimmerCard(height: 240),
      ),
      error: (error, stackTrace) => IaculaErrorState(
        title: 'Não foi possível carregar a reflexão',
        message: 'Tente novamente em instantes.',
        onRetry: () => ref.invalidate(_homeQuoteProvider),
      ),
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
        return ImageBackgroundCard(
          title: entry.title,
          subtitle: entry.content.length > 60
              ? '${entry.content.substring(0, 60)}...'
              : entry.content,
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => PrayerCatalogDetailScreen(entry: entry),
            ),
          ),
          height: 140,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _FeatureRail extends StatelessWidget {
  const _FeatureRail();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.42;

    final cards = [
      _RailCard(label: 'Rosário', isComingSoon: true),
      _RailCard(
        label: 'Confissão',
        isComingSoon: false,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const ExaminationFlowScreen()),
          );
        },
      ),
      _RailCard(label: 'Novenas', isComingSoon: true),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) =>
            SizedBox(width: width, child: cards[index]),
      ),
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({required this.label, this.isComingSoon = false, this.onTap});

  final String label;
  final bool isComingSoon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumTouchableCard(
      onTap: isComingSoon
          ? () => IaculaModal.showAlert(
              context: context,
              title: label,
              message: 'Em breve',
              actionLabel: 'Fechar',
            )
          : onTap,
      child: IaculaSoftCard(
        radius: 16,
        padding: const EdgeInsets.all(IaculaSpacing.md),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                label,
                style: context.textStyles.cardTitle.copyWith(fontSize: 16),
              ),
            ),
            if (isComingSoon)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondaryButton,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Em breve',
                    style: context.textStyles.secondary.copyWith(fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThematicPrayerList extends ConsumerWidget {
  const _ThematicPrayerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(_homeThematicGroupsProvider);

    return groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                child: Hero(
                  tag: 'group_${group.key}',
                  child: ImageBackgroundCard(
                    title: group.label,
                    subtitle: prayerCountLabel(group.itemCount),
                    onTap: () => _openPrayerGroup(context, group),
                    height: 120,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

void _openPrayerGroup(BuildContext context, HomePrayerGroup group) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (_) => PrayerCatalogGroupScreen(
        type: group.type,
        groupKey: group.key,
        title: group.label,
      ),
    ),
  );
}

final _suggestionProvider = FutureProvider<PrayerCatalogEntry?>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref
      .watch(getPrayerCatalogUseCaseProvider)
      .suggestionOfDay(language: settings.language, date: DateTime.now());
});

final _homeThematicGroupsProvider = FutureProvider<List<HomePrayerGroup>>((
  ref,
) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final catalog = await ref
      .watch(getPrayerCatalogUseCaseProvider)
      .listAll(language: settings.language);
  return buildHomeThematicGroups(catalog);
});

final _liturgicalFallbackProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(liturgicalSeasonServiceProvider);
  final context = await service.getCurrentContext();
  final isFallback = context.isFallback;
  debugPrint(
    '[HomeScreen] Liturgical fallback provider resolved: isFallback=$isFallback',
  );
  developer.log(
    'Liturgical fallback provider resolved: isFallback=$isFallback',
    name: 'HomeScreen',
  );
  if (isFallback) {
    developer.log(
      'Liturgical context is fallback; hero will show "Tempo liturgico indisponivel".',
      name: 'HomeScreen',
    );
  }
  return isFallback;
});

final _homeQuoteProvider = FutureProvider<Quote>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final lastDeliveredCardRepo = ref.watch(lastDeliveredCardRepositoryProvider);
  final lastDeliveredCard = await lastDeliveredCardRepo.load();

  if (lastDeliveredCard != null) {
    return lastDeliveredCard.toQuote();
  }

  // Check custom phrases first
  final phrasesAsync = ref.watch(customPhrasesNotifierProvider);
  final phrases = phrasesAsync.valueOrNull ?? [];
  final now = DateTime.now();
  final matching = phrases
      .where((p) => p.isActive && p.displayOnHero && p.schedule.matchesNow(now))
      .toList();

  if (matching.isNotEmpty) {
    // Cycle daily: use day-of-year to rotate
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final selected = matching[dayOfYear % matching.length];
    return Quote(
      text: selected.text,
      dayOfWeek: now.weekday,
      theme: 'personal',
      season: LiturgicalSeason.ordinary,
      imagePath: null, // uses fallback color
    );
  }

  final quote = await ref
      .watch(getNextQuoteUseCaseProvider)
      .call(language: settings.language);
  await lastDeliveredCardRepo.save(
    LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now()),
  );
  return quote;
});
