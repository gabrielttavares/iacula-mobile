import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/local_only_banner.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgia_diaria/presentation/liturgia_screen.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../../quotes/domain/entities/quote.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(_homeQuoteProvider);
    final isFallback = ref.watch(_liturgicalFallbackProvider).valueOrNull ?? false;

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
                        const LocalOnlyBanner(),
                        const _HomeHeader(),
                        const SizedBox(height: IaculaSpacing.lg),
                        _FeatureGrid(
                          onOpenPrayers: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                          onOpenLiturgy: () => Navigator.of(
                            context,
                          ).pushNamed(LiturgiaScreen.routeName),
                          onOpenPremium: () => PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          ),
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        _PromotionalBanner(
                          quote: quote,
                          isFallback: isFallback,
                          onOpenPremium: () => PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          ),
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Destaques'),
                        const SizedBox(height: IaculaSpacing.sm),
                        _HorizontalHighlights(
                          onOpenPrayers: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => const PrayerCollectionsScreen(),
                              ),
                            );
                          },
                          onOpenLiturgy: () => Navigator.of(
                            context,
                          ).pushNamed(LiturgiaScreen.routeName),
                          onOpenPremium: () => PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          ),
                        ),
                        const SizedBox(height: IaculaSpacing.xl),
                        const IaculaSectionHeader(title: 'Orações diárias'),
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
    final greeting = authState.whenData((user) {
      final name = user?.displayName;
      return name != null && name.isNotEmpty ? 'Paz e bem, $name!' : 'Paz e bem!';
    }).value ?? 'Paz e bem!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(CupertinoIcons.circle_grid_3x3_fill, size: 18),
                SizedBox(width: 8),
                Text('Iacula', style: IaculaText.cardTitle),
              ],
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.bell,
                    color: IaculaColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: () {},
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

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenPremium,
  });

  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SquareFeatureCard(
            icon: CupertinoIcons.book,
            label: 'Orações',
            onTap: onOpenPrayers,
          ),
        ),
        const SizedBox(width: IaculaSpacing.sm),
        Expanded(
          child: _SquareFeatureCard(
            icon: CupertinoIcons.doc_text,
            label: 'Liturgia',
            onTap: onOpenLiturgy,
          ),
        ),
        const SizedBox(width: IaculaSpacing.sm),
        Expanded(
          child: _SquareFeatureCard(
            icon: CupertinoIcons.star_fill,
            label: 'Premium',
            onTap: onOpenPremium,
          ),
        ),
      ],
    );
  }
}

class _SquareFeatureCard extends StatelessWidget {
  const _SquareFeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: IaculaSoftCard(
          radius: 18,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: IaculaColors.primaryButton),
              const SizedBox(height: IaculaSpacing.sm),
              Text(
                label,
                style: IaculaText.cardTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionalBanner extends ConsumerWidget {
  const _PromotionalBanner({
    required this.quote,
    required this.onOpenPremium,
    this.isFallback = false,
  });

  final Quote quote;
  final VoidCallback onOpenPremium;
  final bool isFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IaculaRadius.banner),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IaculaRadius.banner),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (quote.imagePath != null)
              Image.asset(
                quote.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF3D3125)),
                ),
              )
            else
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF3D3125)),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.3),
                    CupertinoColors.black.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: () async {
                          final repo = ref.read(favoriteRepositoryProvider);
                          final alreadySaved = await repo.isFavorite(quote.text);
                          if (!alreadySaved) {
                            await repo.save(FavoriteItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              quoteText: quote.text,
                              theme: quote.theme,
                              season: quote.season.name,
                              savedAt: DateTime.now(),
                              imagePath: quote.imagePath,
                              feastName: quote.feastName,
                            ));
                          }
                        },
                        child: const Icon(
                          CupertinoIcons.bookmark,
                          color: CupertinoColors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    quote.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFF6F6F8),
                      height: 1.5,
                    ),
                  ),
                  if (isFallback)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Tempo litúrgico indisponível',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0x99F6F6F8),
                        ),
                      ),
                    ),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minSize: 0,
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: onOpenPremium,
                    child: const Text(
                      'Conhecer Premium',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalHighlights extends StatelessWidget {
  const _HorizontalHighlights({
    required this.onOpenPrayers,
    required this.onOpenLiturgy,
    required this.onOpenPremium,
  });

  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenLiturgy;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _HighlightCard(
            width: width,
            title: 'Liturgia diária',
            subtitle: 'Leituras e orações de hoje',
            onTap: onOpenLiturgy,
          ),
          const SizedBox(width: IaculaSpacing.sm),
          _HighlightCard(
            width: width,
            title: 'Orações do dia a dia',
            subtitle: 'Orações para manhã, tarde e noite.',
            onTap: onOpenPrayers,
          ),
          const SizedBox(width: IaculaSpacing.sm),
          _HighlightCard(
            width: width,
            title: 'Homilias diárias',
            subtitle: 'Disponível no Premium.',
            onTap: onOpenPremium,
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: IaculaSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: IaculaText.cardTitle),
              const SizedBox(height: 6),
              Text(subtitle, style: IaculaText.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyPrayerList extends StatelessWidget {
  const _DailyPrayerList();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Oferecimento da manhã', '2 min'),
      ('Angelus', '3 min'),
      ('Exame do dia', '5 min'),
    ];

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
            child: IaculaSoftCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: _PrayerListItem(
                title: item.$1,
                subtitle: item.$2,
                avatarLabel: item.$1[0],
              ),
            ),
          ),
      ],
    );
  }
}

class _ThematicPrayerRail extends StatelessWidget {
  const _ThematicPrayerRail();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    const cards = [
      ('Família', 'Unidade, perdão e caridade no lar.'),
      ('Trabalho', 'Discernimento, humildade e constância.'),
      ('Enfermidade', 'Consolo, esperança e fortaleza.'),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) {
          final card = cards[index];
          return SizedBox(
            width: width,
            child: IaculaSoftCard(
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(card.$1, style: IaculaText.cardTitle),
                  const SizedBox(height: 6),
                  Text(card.$2, style: IaculaText.secondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SaintPrayerList extends StatelessWidget {
  const _SaintPrayerList();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('São José', 'Intercessão pela família', 'SJ'),
      ('Santa Teresinha', 'Pequena via de amor e confiança', 'ST'),
      ('São Bento', 'Firmeza espiritual e proteção', 'SB'),
    ];

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
            child: IaculaSoftCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: _PrayerListItem(
                title: item.$1,
                subtitle: item.$2,
                avatarLabel: item.$3,
              ),
            ),
          ),
      ],
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
