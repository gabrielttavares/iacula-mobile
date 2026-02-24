import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgia_diaria/presentation/liturgia_screen.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../prayers/presentation/prayer_collections_screen.dart';
import '../../quotes/domain/entities/quote.dart';
import '../../settings/domain/entities/settings.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(_dashboardProvider);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: dashboard.when(
          data: (data) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(IaculaSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const IaculaLargeTitle('Olá, Pedro'),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                                ref.invalidate(_dashboardProvider);
                              },
                              child: const Icon(
                                CupertinoIcons.slider_horizontal_3,
                                color: IaculaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _QuickActionCard(
                                icon: CupertinoIcons.book,
                                title: 'Orações',
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                          const PrayerCollectionsScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: IaculaSpacing.sm),
                              _QuickActionCard(
                                icon: CupertinoIcons.calendar,
                                title: 'Novenas',
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                          const _NovenasPlaceholderScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: IaculaSpacing.sm),
                              _QuickActionCard(
                                icon: CupertinoIcons.doc_text,
                                title: 'Liturgia Diária',
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(LiturgiaScreen.routeName),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        SizedBox(
                          height: 320,
                          child: _QuoteCard(quote: data.quote),
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        const IaculaSectionHeader(title: 'Premium'),
                        const SizedBox(height: IaculaSpacing.sm),
                        _PremiumSection(),
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        radius: 16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: IaculaColors.primaryButton),
            const SizedBox(width: 8),
            Text(title, style: IaculaText.cardTitle),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final label = quote.feastName ?? _seasonLabel(quote.season.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (quote.imagePath != null)
              Image.asset(
                quote.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => const DecoratedBox(
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
                    CupertinoColors.black.withValues(alpha: 0.67),
                    CupertinoColors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        quote.text,
                        style: IaculaText.secondary.copyWith(
                          color: const Color(0xFFF8EFE1),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: IaculaText.secondary.copyWith(
                      color: const Color(0xD8D6BA8E),
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

  String _seasonLabel(String season) {
    switch (season) {
      case 'advent':
        return 'tempo do advento';
      case 'lent':
        return 'tempo da quaresma';
      case 'easter':
        return 'tempo pascal';
      case 'christmas':
        return 'tempo do natal';
      default:
        return 'tempo comum';
    }
  }
}

class _NovenasPlaceholderScreen extends StatelessWidget {
  const _NovenasPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Novenas')),
      child: Center(child: Text('Em breve...')),
    );
  }
}

class _PremiumCardData {
  const _PremiumCardData({
    required this.icon,
    required this.title,
    required this.feature,
  });

  final IconData icon;
  final String title;
  final PremiumFeature feature;
}

const _premiumCards = [
  _PremiumCardData(
    icon: CupertinoIcons.circle_grid_3x3,
    title: 'Rosário',
    feature: PremiumFeature.rosary,
  ),
];

class _PremiumSection extends StatelessWidget {
  const _PremiumSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final card in _premiumCards)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () =>
                  PremiumGate.showModal(context, feature: card.feature),
              child: IaculaSoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                radius: 16,
                child: Row(
                  children: [
                    Icon(
                      card.icon,
                      size: 20,
                      color: IaculaColors.primaryButton,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(card.title, style: IaculaText.cardTitle),
                    ),
                    const Icon(
                      CupertinoIcons.lock,
                      size: 16,
                      color: IaculaColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final _dashboardProvider = FutureProvider<_DashboardData>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final lastDeliveredCardRepo = ref.watch(lastDeliveredCardRepositoryProvider);
  final lastDeliveredCard = await lastDeliveredCardRepo.load();

  Quote quote;
  if (lastDeliveredCard != null) {
    quote = lastDeliveredCard.toQuote();
  } else {
    quote = await ref
        .watch(getNextQuoteUseCaseProvider)
        .call(language: settings.language);
    await lastDeliveredCardRepo.save(
      LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now()),
    );
  }

  return _DashboardData(settings: settings, quote: quote);
});

final class _DashboardData {
  const _DashboardData({required this.settings, required this.quote});

  final Settings settings;
  final Quote quote;
}
