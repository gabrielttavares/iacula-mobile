import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/premium_feature.dart';
import 'paywall_screen.dart';
import 'premium_copy.dart';

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
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) =>
          lockedFallback ?? _LockedFallback(feature: feature),
    );
  }

  static bool _isPremiumFeature(PremiumFeature value) {
    return switch (value) {
      PremiumFeature.meditation ||
      PremiumFeature.planOfLife ||
      PremiumFeature.streakDashboard ||
      PremiumFeature.rosary ||
      PremiumFeature.leituras ||
      PremiumFeature.journal ||
      PremiumFeature.nightPrayer ||
      PremiumFeature.liturgyOfHours ||
      PremiumFeature.widgets => true,
    };
  }

  static void showModal(
    BuildContext context, {
    required PremiumFeature feature,
  }) {
    IaculaModal.showSheet<void>(
      context: context,
      builder: (context) => _PremiumGateModal(feature: feature),
    );
  }
}

class _LockedFallback extends StatelessWidget {
  const _LockedFallback({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final copy = premiumCopyFor(feature);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: IaculaSoftCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.lock,
                size: 48,
                color: context.colors.primaryButton,
              ),
              const SizedBox(height: 16),
              Text(
                'Continue com o Premium',
                textAlign: TextAlign.center,
                style: context.textStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              Text(
                copy.gateMessage,
                textAlign: TextAlign.center,
                style: context.textStyles.secondary,
              ),
              const SizedBox(height: 24),
              IaculaPrimaryPillButton(
                label: 'Conhecer o Premium',
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const PaywallScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _PremiumGateModal extends StatelessWidget {
  const _PremiumGateModal({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final copy = premiumCopyFor(feature);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              CupertinoIcons.lock,
              size: 48,
              color: context.colors.primaryButton,
            ),
            const SizedBox(height: 16),
            Text(
              'Continue com o Premium',
              textAlign: TextAlign.center,
              style: context.textStyles.sectionTitle,
            ),
            const SizedBox(height: 12),
            Text(
              copy.gateMessage,
              textAlign: TextAlign.center,
              style: context.textStyles.secondary,
            ),
            const SizedBox(height: 24),
            IaculaPrimaryPillButton(
              label: 'Conhecer o Premium',
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            IaculaSecondaryPillButton(
              label: 'Agora não',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
