import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';

import '../../../core/presentation/widgets/iacula_horizontal_card_rail.dart';
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
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../challenges/domain/entities/challenge.dart';
import '../../challenges/presentation/challenge_detail_screen.dart';
import '../../challenges/presentation/challenge_library_screen.dart';
import '../../prayer_intentions/presentation/prayer_intentions_screen.dart';
import '../../confession/presentation/confession_flow_screen.dart';
import '../../examination/presentation/examination_reading_screen.dart';
import '../../quotes/domain/entities/quote.dart';
import '../../rosary/presentation/rosary_intro_screen.dart';
import '../../bible/presentation/bible_books_screen.dart';
import '../../leituras/presentation/pages/leituras_home_page.dart';
import 'hero_reflection_sheet.dart';
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
                leading: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Image.asset(
                    'assets/images/icon.png',
                    height: 28,
                    width: 28,
                  ),
                ),
                largeTitle: Text(greeting),
                middle: const SizedBox.shrink(),
                alwaysShowMiddle: false,
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
                        const SizedBox(height: IaculaSpacing.lg),
                        _HomeShortcutsRail(
                          onOpenCustomPhrases: () {
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
                          onOpenLeituras: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const LeiturasHomePage(),
                              ),
                            );
                          },
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
                                builder: (_) =>
                                    const ExaminationReadingScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Ação de Graças'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _DailyPrayerList(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const _MonthlyNovenasSection(),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Explore'),
                        const SizedBox(height: IaculaSpacing.sm),
                        const _FeatureCardsList(),
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

class _HomeShortcutsRail extends StatelessWidget {
  const _HomeShortcutsRail({
    required this.onOpenCustomPhrases,
    required this.onOpenLeituras,
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenIntentions,
    required this.onOpenExamination,
  });

  final VoidCallback onOpenCustomPhrases;
  final VoidCallback onOpenLeituras;
  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenIntentions;
  final VoidCallback onOpenExamination;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.42;

    final cards = [
      _RailCard(
        key: const Key('home_action_oracoes'),
        label: 'Orações',
        onTap: onOpenPrayers,
      ),
      _RailCard(
        key: const Key('home_action_liturgia'),
        label: 'Liturgia diária',
        onTap: onOpenLiturgy,
      ),
      _RailCard(
        key: const Key('home_action_intencoes'),
        label: 'Intenções',
        onTap: onOpenIntentions,
      ),
      _RailCard(
        key: const Key('home_action_exame'),
        label: 'Exame Diário',
        onTap: onOpenExamination,
      ),
      _RailCard(
        key: const Key('home_custom_phrases_card'),
        label: 'Minhas frases',
        onTap: onOpenCustomPhrases,
      ),
      _RailCard(
        key: const Key('home_leituras_chip'),
        label: 'Leituras',
        onTap: onOpenLeituras,
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        key: const Key('home_shortcuts_rail'),
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
      loading: () =>
          const SizedBox(height: 240, child: IaculaShimmerCard(height: 240)),
      error: (error, stackTrace) => IaculaErrorState(
        title: 'Não conseguimos abrir a reflexão de agora',
        message:
            'Tente novamente em instantes para retomar seu momento de oração.',
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

class _FeatureCardsList extends StatelessWidget {
  const _FeatureCardsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
          child: ImageBackgroundCard(
            key: const Key('home_feature_biblia_card'),
            title: 'Bíblia',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const BibleBooksScreen()),
              );
            },
            height: 120,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
          child: ImageBackgroundCard(
            key: const Key('home_feature_rosario_card'),
            title: 'Rosário',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const RosaryIntroScreen(),
                ),
              );
            },
            height: 120,
          ),
        ),
        ImageBackgroundCard(
          key: const Key('home_feature_confissao_card'),
          title: 'Sacramento da Confissão',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const ConfessionFlowScreen(),
              ),
            );
          },
          height: 120,
        ),
      ],
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        padding: const EdgeInsets.all(IaculaSpacing.md),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            label,
            style: context.textStyles.cardTitle.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _MonthlyNovenasSection extends ConsumerWidget {
  const _MonthlyNovenasSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(homeNowProvider);
    final catalogAsync = ref.watch(challengeCatalogProvider);

    return catalogAsync.when(
      data: (catalog) {
        final items = _monthlyNovenasFor(now, catalog);
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IaculaSectionHeader(title: 'Novenas deste mês'),
            const SizedBox(height: 12),
            IaculaHorizontalCardRail(
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _MonthlyNovenaCard(item: items[index]),
            ),
            const SizedBox(height: 12),
            Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ChallengeLibraryScreen(),
                    ),
                  );
                },
                child: Text(
                  'Ver todas',
                  style: context.textStyles.secondary.copyWith(
                    color: context.colors.primaryButton,
                    fontWeight: FontWeight.w700,
                  ),
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

class _MonthlyNovenaCard extends StatelessWidget {
  const _MonthlyNovenaCard({required this.item});

  final _ResolvedMonthlyNovena item;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ChallengeDetailScreen(challenge: item.challenge),
          ),
        );
      },
      child: IaculaSoftCard(
        showShadow: true,
        padding: EdgeInsets.zero,
        radius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.primaryButton.withValues(alpha: 0.2),
                            context.colors.primaryButton.withValues(
                              alpha: 0.08,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.book,
                          size: 28,
                          color: context.colors.primaryButton,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  _NovenaDateBadge(text: item.dateLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NovenaDateBadge extends StatelessWidget {
  const _NovenaDateBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.secondaryButton,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 14,
            color: context.colors.primaryButton,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.secondary.copyWith(
                color: context.colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _suggestionProvider = FutureProvider<PrayerCatalogEntry?>((ref) async {
  final now = ref.watch(homeNowProvider);
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref
      .watch(getPrayerCatalogUseCaseProvider)
      .suggestionOfDay(language: settings.language, date: now);
});

final homeNowProvider = Provider<DateTime>((ref) => DateTime.now());

List<_ResolvedMonthlyNovena> _monthlyNovenasFor(
  DateTime date,
  List<Challenge> catalog,
) {
  final challengeById = {
    for (final challenge in catalog) challenge.id: challenge,
  };

  return _monthlyNovenaCatalog
      .where((item) => item.month == date.month)
      .map((item) {
        final challenge = challengeById[item.challengeId];
        if (challenge == null) return null;
        return _ResolvedMonthlyNovena(item: item, challenge: challenge);
      })
      .whereType<_ResolvedMonthlyNovena>()
      .toList(growable: false);
}

final class _MonthlyNovenaItem {
  const _MonthlyNovenaItem({
    required this.challengeId,
    required this.title,
    required this.dateLabel,
    required this.imageAsset,
    required this.month,
  });

  final String challengeId;
  final String title;
  final String dateLabel;
  final String imageAsset;
  final int month;
}

final class _ResolvedMonthlyNovena {
  const _ResolvedMonthlyNovena({required this.item, required this.challenge});

  final _MonthlyNovenaItem item;
  final Challenge challenge;

  String get title => item.title;
  String get dateLabel => item.dateLabel;
  String get imageAsset => item.imageAsset;
}

const _monthlyNovenaCatalog = <_MonthlyNovenaItem>[
  _MonthlyNovenaItem(
    challengeId: 'novena_da_familia',
    title: 'Novena à Sagrada Família',
    dateLabel: '20 a 28 de janeiro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 1,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_nossa_senhora_lourdes',
    title: 'Novena a Nossa Senhora de Lourdes',
    dateLabel: '2 a 10 de fevereiro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 2,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_patricio',
    title: 'Novena a São Patrício',
    dateLabel: '8 a 16 de março',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 3,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_jose',
    title: 'Novena a São José',
    dateLabel: '10 a 18 de março',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 3,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_anunciacao',
    title: 'Novena da Anunciação',
    dateLabel: '16 a 24 de março',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 3,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_gemma_galgani',
    title: 'Novena a Santa Gemma Galgani',
    dateLabel: '2 a 10 de abril',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 4,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_bernadette',
    title: 'Novena a Santa Bernadette',
    dateLabel: '8 a 16 de abril',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 4,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_jorge',
    title: 'Novena a São Jorge',
    dateLabel: '14 a 22 de abril',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 4,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_catarina_sena',
    title: 'Novena a Santa Catarina de Sena',
    dateLabel: '20 a 28 de abril',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 4,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_nossa_senhora_fatima',
    title: 'Novena a Nossa Senhora de Fátima',
    dateLabel: '4 a 12 de maio',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 5,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_espirito_santo',
    title: 'Novena ao Espírito Santo',
    dateLabel: 'móvel conforme Pentecostes',
    imageAsset: 'assets/placeholders/novenas/espirito-santo.png',
    month: 5,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_rita_cassia',
    title: 'Novena a Santa Rita de Cássia',
    dateLabel: '14 a 22 de maio',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 5,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santo_antonio',
    title: 'Novena a Santo Antônio',
    dateLabel: '4 a 12 de junho',
    imageAsset: 'assets/placeholders/novenas/santo-antonio.png',
    month: 6,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sagrado_coracao',
    title: 'Novena ao Sagrado Coração de Jesus',
    dateLabel: 'móvel após Corpus Christi',
    imageAsset: 'assets/placeholders/novenas/sagrado-coracao.png',
    month: 6,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_pedro',
    title: 'Novena a São Pedro',
    dateLabel: '20 a 28 de junho',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 6,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_nossa_senhora_carmo',
    title: 'Novena a Nossa Senhora do Carmo',
    dateLabel: '7 a 15 de julho',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 7,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santana',
    title: 'Novena a Sant\'Ana',
    dateLabel: '17 a 25 de julho',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 7,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_joao_maria_vianney',
    title: 'Novena a São João Maria Vianney',
    dateLabel: '27 de julho a 4 de agosto',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 8,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_assuncao_nossa_senhora',
    title: 'Novena da Assunção de Nossa Senhora',
    dateLabel: '6 a 14 de agosto',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 8,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_nossa_senhora_rainha',
    title: 'Novena a Nossa Senhora Rainha',
    dateLabel: '14 a 22 de agosto',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 8,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_miguel',
    title: 'Novena a São Miguel Arcanjo',
    dateLabel: '20 a 28 de setembro',
    imageAsset: 'assets/placeholders/novenas/sao-miguel.png',
    month: 9,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_teresa_avila',
    title: 'Novena a Santa Teresa de Ávila',
    dateLabel: '6 a 14 de outubro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 10,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_judas_tadeu',
    title: 'Novena a São Judas Tadeu',
    dateLabel: '20 a 28 de outubro',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 10,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_sao_martinho_tours',
    title: 'Novena a São Martinho de Tours',
    dateLabel: '2 a 10 de novembro',
    imageAsset: 'assets/placeholders/novenas/sao-jose.png',
    month: 11,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_medalha_milagrosa',
    title: 'Novena da Medalha Milagrosa',
    dateLabel: '18 a 26 de novembro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 11,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_imaculada_conceicao',
    title: 'Novena da Imaculada Conceição',
    dateLabel: '29 de novembro a 7 de dezembro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 12,
  ),
  _MonthlyNovenaItem(
    challengeId: 'novena_santa_luzia',
    title: 'Novena a Santa Luzia',
    dateLabel: '4 a 12 de dezembro',
    imageAsset: 'assets/placeholders/novenas/nossa-senhora.png',
    month: 12,
  ),
];

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

  if (settings.escrivaPointsFeedEnabled) {
    final quote = await ref
        .watch(getNextEscrivaPointsQuoteUseCaseProvider)
        .call(language: settings.language);
    await lastDeliveredCardRepo.save(
      LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now()),
    );
    return quote;
  }

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
      source: QuoteSource.personal,
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
