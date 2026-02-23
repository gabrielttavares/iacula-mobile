import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_feature.dart';
import 'package:iacula_app/features/premium/presentation/paywall_screen.dart';

class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    required this.feature,
    required this.child,
    this.lockedFallback,
    super.key,
  });

  final PremiumFeature feature;
  final Widget child;
  final Widget? lockedFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(premiumStatusProvider);

    return status.when(
      data: (value) {
        if (!_isPremiumFeature(feature) || value.isPremium) {
          return child;
        }

        return lockedFallback ?? _LockedFallback(feature: feature);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => lockedFallback ?? _LockedFallback(feature: feature),
    );
  }

  bool _isPremiumFeature(PremiumFeature value) {
    return switch (value) {
      PremiumFeature.meditation ||
      PremiumFeature.planOfLife ||
      PremiumFeature.settings => true,
    };
  }
}

final class _LockedFallback extends StatelessWidget {
  const _LockedFallback({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 42),
            const SizedBox(height: 10),
            Text(
              '${_label(feature)} e um recurso premium.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              child: const Text('Ver Premium'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(PremiumFeature value) {
    return switch (value) {
      PremiumFeature.meditation => 'Meditacao',
      PremiumFeature.planOfLife => 'Plano de Vida',
      PremiumFeature.settings => 'Configuracoes',
    };
  }
}
