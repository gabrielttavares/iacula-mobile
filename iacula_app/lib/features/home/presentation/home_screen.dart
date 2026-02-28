import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';

import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/image_background_card.dart';
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
import '../../quotes/domain/entities/quote.dart';
import 'widgets/home_action_grid.dart';
import 'widgets/home_continuation_card.dart';
import 'widgets/home_hero_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animateIn = true);
      }
    });
  }

  Future<void> _showEmBreveDialog(BuildContext context, String title) {
    return IaculaModal.showAlert(
      context: context,
      title: title,
      message: 'Em breve',
      actionLabel: 'Fechar',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFallback =
        ref.watch(_liturgicalFallbackProvider).valueOrNull ?? false;

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Center(
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
                      _AnimatedHomeBlock(
                        visible: _animateIn,
                        offsetY: 0.04,
                        child: _HomeHeroSection(
                          isFallback: isFallback,
                          onOpenPremium: () => PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          ),
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.lg),
                      _AnimatedHomeBlock(
                        visible: _animateIn,
                        offsetY: 0.06,
                        child: HomeActionGrid(
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
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.md),
                      _AnimatedHomeBlock(
                        visible: _animateIn,
                        offsetY: 0.08,
                        child: HomeContinuationCard(
                          title: 'Continue seu caminho',
                          subtitle: 'Retome suas orações favoritas',
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                        ),
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
      ),
    );
  }
}

class _AnimatedHomeBlock extends StatelessWidget {
  const _AnimatedHomeBlock({
    required this.visible,
    required this.offsetY,
    required this.child,
  });

  final bool visible;
  final double offsetY;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : Offset(0, offsetY),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        opacity: visible ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _HomeHeroSection extends ConsumerWidget {
  const _HomeHeroSection({
    required this.isFallback,
    required this.onOpenPremium,
  });

  final bool isFallback;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(_homeQuoteProvider);
    return quoteAsync.when(
      data: (quote) => HomeHeroCard(
        quote: quote,
        isFallback: isFallback,
        onOpenPremium: onOpenPremium,
      ),
      loading: () => const SizedBox(
        height: 240,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, stackTrace) => IaculaErrorState(
        title: 'Não foi possível carregar a reflexão',
        message: 'Tente novamente em instantes.',
        onRetry: () => ref.invalidate(_homeQuoteProvider),
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
            Text('Iacula', style: IaculaText.cardTitle),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
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
                  minimumSize: const Size(32, 32),
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
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
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
            separatorBuilder: (context, index) =>
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
              return SizedBox(
                width: width,
                child: ImageBackgroundCard(
                  title: entry.title,
                  subtitle: themeLabel,
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => PrayerCatalogDetailScreen(entry: entry),
                    ),
                  ),
                  height: 132,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
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
                child: ImageBackgroundCard(
                  title: entry.title,
                  subtitle: entry.saints
                      .map((s) => _saintLabels[s] ?? s)
                      .join(', '),
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => PrayerCatalogDetailScreen(entry: entry),
                    ),
                  ),
                  height: 120,
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
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
