import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/premium_feature.dart';
import 'paywall_screen.dart';

class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    required this.feature,
    required this.child,
    this.lockedFallback,
    super.key,
  });

  static bool debugPremiumBypass = kDebugMode;

  final PremiumFeature feature;
  final Widget child;
  final Widget? lockedFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(premiumStatusProvider);

    return status.when(
      data: (value) {
        if (debugPremiumBypass || !_isPremiumFeature(feature) || value.isPremium) {
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
      PremiumFeature.settings ||
      PremiumFeature.rosary ||
      PremiumFeature.novenas => true,
    };
  }

  static void showModal(
    BuildContext context, {
    required PremiumFeature feature,
  }) {
    if (debugPremiumBypass) return;
    showCupertinoModalPopup<void>(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: IaculaSoftCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.lock,
                size: 48,
                color: IaculaColors.primaryButton,
              ),
              const SizedBox(height: 16),
              const Text(
                'Funcionalidade Premium',
                textAlign: TextAlign.center,
                style: IaculaText.sectionTitle,
              ),
              const SizedBox(height: 12),
              Text(
                '${_label(feature)} está disponível após o pagamento único de R\$ 39,90.',
                textAlign: TextAlign.center,
                style: IaculaText.secondary,
              ),
              const SizedBox(height: 24),
              IaculaPrimaryPillButton(
                label: 'Desbloquear Agora',
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.lock,
                size: 48,
                color: IaculaColors.primaryButton,
              ),
              const SizedBox(height: 16),
              const Text(
                'Funcionalidade Premium',
                textAlign: TextAlign.center,
                style: IaculaText.sectionTitle,
              ),
              const SizedBox(height: 12),
              Text(
                '${_LockedFallback._label(feature)} está disponível após o pagamento único de R\$ 39,90.',
                textAlign: TextAlign.center,
                style: IaculaText.secondary,
              ),
              const SizedBox(height: 24),
              IaculaPrimaryPillButton(
                label: 'Desbloquear Agora',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const PaywallScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              IaculaSecondaryPillButton(
                label: 'Mais tarde',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
