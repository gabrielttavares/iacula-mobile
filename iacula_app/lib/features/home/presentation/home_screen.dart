import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
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

    return Scaffold(
      body: SafeArea(
        child: dashboard.when(
          data: (data) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Olá, Pedro',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: IconButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                                ref.invalidate(_dashboardProvider);
                              },
                              icon: const Icon(Icons.tune_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: [
                            _QuickActionCard(
                              icon: Icons.menu_book,
                              title: 'Orações',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PrayerCollectionsScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _QuickActionCard(
                              icon: Icons.calendar_today,
                              title: 'Novenas',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const _NovenasPlaceholderScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _QuickActionCard(
                              icon: Icons.auto_stories,
                              title: 'Liturgia Diária',
                              onTap: () => Navigator.of(context).pushNamed(LiturgiaScreen.routeName),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _QuoteCard(quote: data.quote)),
                            const SizedBox(height: 24),
                            _PremiumSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stack) => Center(
            child: Text(
              'Erro: $error',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
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
            color: Colors.black.withValues(alpha: 0.08),
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
                    Colors.black.withValues(alpha: 0.67),
                    Colors.black.withValues(alpha: 0.9),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF8EFE1),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    return Scaffold(
      appBar: AppBar(title: const Text('Novenas')),
      body: const Center(child: Text('Em breve...')),
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
    icon: Icons.adjust,
    title: 'Rosário',
    feature: PremiumFeature.rosary,
  ),
];

class _PremiumSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Premium',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (final card in _premiumCards)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => PremiumGate.showModal(context, feature: card.feature),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(card.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        card.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.lock_outline, size: 16, color: Colors.black38),
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
