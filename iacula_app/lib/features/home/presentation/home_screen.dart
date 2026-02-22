import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../notifications/domain/entities/last_delivered_card.dart';
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
                          const SizedBox(width: 48),
                          Text(
                            'I A C U L A',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 4.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: IconButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                                ref.invalidate(_dashboardProvider);
                              },
                              icon: const Icon(Icons.tune_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ultima jaculatoria',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF837562).withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _QuoteCard(quote: data.quote),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stack) => Center(
            child: Text('Erro: $error', style: Theme.of(context).textTheme.bodyLarge),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA000000), Color(0xE6000000)],
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

final _dashboardProvider = FutureProvider<_DashboardData>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  final lastDeliveredCardRepo = ref.watch(lastDeliveredCardRepositoryProvider);
  final lastDeliveredCard = await lastDeliveredCardRepo.load();

  Quote quote;
  if (lastDeliveredCard != null) {
    quote = lastDeliveredCard.toQuote();
  } else {
    quote = await ref.watch(getNextQuoteUseCaseProvider).call(language: settings.language);
    await lastDeliveredCardRepo.save(
      LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now()),
    );
  }

  return _DashboardData(settings: settings, quote: quote);
});

final class _DashboardData {
  const _DashboardData({
    required this.settings,
    required this.quote,
  });

  final Settings settings;
  final Quote quote;
}
