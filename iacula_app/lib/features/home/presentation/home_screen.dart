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
                      // Template Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose your',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Design Course',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                              );
                              ref.invalidate(_dashboardProvider);
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar (Dummy)
                      Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFB),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Search for course',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFFB9BABC),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.search, color: Color(0xFFB9BABC)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Category title
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: [
                            _QuickActionCard(
                              title: 'Orações',
                              isSelected: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PrayerCollectionsScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _QuickActionCard(
                              title: 'Novenas',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const _NovenasPlaceholderScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _QuickActionCard(
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
    required this.title,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary : surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primary),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.27,
            color: isSelected ? surface : primary,
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Popular Course',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        for (final card in _premiumCards)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => PremiumGate.showModal(context, feature: card.feature),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(card.icon, size: 24, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24 lesson',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '4.3',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Icon(Icons.star, color: colorScheme.primary, size: 20),
                      ],
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
