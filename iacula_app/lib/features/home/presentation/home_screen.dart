import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_stagger_entrance.dart';
import '../../../core/presentation/widgets/image_background_card.dart';
import '../../../core/presentation/widgets/premium_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/domain/entities/auth_user.dart';
import '../../custom_phrases/presentation/custom_phrases_screen.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
import '../../search/presentation/search_screen.dart';
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../prayer_intentions/presentation/prayer_intentions_screen.dart';
import '../../confession/presentation/confession_flow_screen.dart';
import '../../quotes/domain/entities/quote.dart';
import '../../examination/presentation/examination_reading_screen.dart';
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
                trailing: CupertinoButton(
                  key: const Key('home_search_button'),
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
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  ref.invalidate(_homeQuoteProvider);

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
                        _PermissionBanner(),
                        _HomeHeroSection(
                          isFallback: isFallback,
                          onHeroTap: (quote) =>
                              HeroReflectionSheet.show(context, quote: quote),
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        _HomeShortcutsRail(
                          onOpenConfession: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const ConfessionFlowScreen(),
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
                          onOpenExame: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const ExaminationReadingScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
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
    required this.onOpenConfession,
    required this.onOpenPrayers,
    required this.onOpenExame,
  });

  final VoidCallback onOpenConfession;
  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenExame;

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
        key: const Key('home_action_exame'),
        label: 'Exame Diário',
        onTap: onOpenExame,
      ),
      _RailCard(
        key: const Key('home_feature_confissao_card'),
        label: 'Confissão',
        onTap: onOpenConfession,
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
    final settingsAsync = ref.watch(_heroSettingsProvider);
    final intervalMinutes = settingsAsync.valueOrNull?.intervalMinutes ?? 15;
    final notificationsEnabled =
        settingsAsync.valueOrNull?.notificationsEnabled ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        quoteAsync.when(
          data: (quote) => HomeHeroCard(
            quote: quote,
            isFallback: isFallback,
            onTap: onHeroTap,
          ),
          loading: () => const SizedBox(
            height: 240,
            child: IaculaShimmerCard(height: 240),
          ),
          error: (error, stackTrace) => IaculaErrorState(
            title: 'Não conseguimos abrir a reflexão de agora',
            message:
                'Tente novamente em instantes para retomar seu momento de oração.',
            onRetry: () => ref.invalidate(_homeQuoteProvider),
          ),
        ),
        if (notificationsEnabled) ...[
          const SizedBox(height: 8),
          _NotificationContextLabel(intervalMinutes: intervalMinutes),
        ],
      ],
    );
  }
}

class _PermissionBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionGranted = ref.watch(notificationPermissionProvider);
    final notificationsEnabled = ref.watch(
      _heroSettingsProvider.select(
        (s) => s.valueOrNull?.notificationsEnabled ?? true,
      ),
    );

    if (permissionGranted || !notificationsEnabled) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(IaculaSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(IaculaRadius.small),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: context.colors.warning,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Notificações bloqueadas. Ative nas Configurações do sistema para receber jaculatórias.',
                style: context.textStyles.secondary.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationContextLabel extends StatelessWidget {
  const _NotificationContextLabel({required this.intervalMinutes});

  final int intervalMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.bell,
          size: 13,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            'Jaculatórias a cada ${intervalMinutes}min \u00B7 Angelus ao meio-dia',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.secondary.copyWith(fontSize: 12),
          ),
        ),
      ],
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
            key: const Key('home_action_intencoes'),
            title: 'Intenções',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const PrayerIntentionsScreen(),
                ),
              );
            },
            height: 120,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
          child: ImageBackgroundCard(
            key: const Key('home_custom_phrases_card'),
            title: 'Minhas frases',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const CustomPhrasesScreen(),
                ),
              );
            },
            height: 120,
          ),
        ),
      ],
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({super.key, required this.label, this.onTap});

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

final _heroSettingsProvider = FutureProvider((ref) {
  return ref.watch(getSettingsUseCaseProvider).call();
});

final homeNowProvider = Provider<DateTime>((ref) => DateTime.now());

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
