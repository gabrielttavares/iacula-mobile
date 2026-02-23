import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../domain/entities/premium_feature.dart';
import 'paywall_screen.dart';

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
      error: (error, stackTrace) => lockedFallback ?? _LockedFallback(feature: feature),
    );
  }

  static bool _isPremiumFeature(PremiumFeature value) {
    return switch (value) {
      PremiumFeature.meditation ||
      PremiumFeature.planOfLife ||
      PremiumFeature.settings ||
      PremiumFeature.rosary ||
      PremiumFeature.novenas => true,
    };
  }

  static void showModal(BuildContext context, {required PremiumFeature feature}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumGateModal(feature: feature),
    );
  }
}

class _LockedFallback extends StatelessWidget {
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
            Icon(Icons.lock_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Funcionalidade Premium',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_label(feature)} está disponível após o pagamento único de R\$ 29,90.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Desbloquear Agora'),
            ),
          ],
        ),
      ),
    );
  }

  static String _label(PremiumFeature value) {
    return switch (value) {
      PremiumFeature.meditation => 'A Meditação',
      PremiumFeature.planOfLife => 'O Plano de Vida',
      PremiumFeature.settings => 'As Configurações',
      PremiumFeature.rosary => 'O Rosário',
      PremiumFeature.novenas => 'As Novenas',
    };
  }
}

class _PremiumGateModal extends StatelessWidget {
  const _PremiumGateModal({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionalidade Premium',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_LockedFallback._label(feature)} está disponível após o pagamento único de R\$ 29,90.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close modal
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Desbloquear Agora'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Mais tarde'),
            ),
          ],
        ),
      ),
    );
  }
}
