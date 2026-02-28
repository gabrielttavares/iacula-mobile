import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../application/premium_bloc.dart';

const premiumLifetimeProductId = 'premium_lifetime';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  StreamSubscription<PremiumState>? _stateSub;
  bool _pendingPurchaseAfterSignIn = false;

  @override
  void initState() {
    super.initState();
    final bloc = ref.read(premiumBlocProvider);
    _stateSub = bloc.states.listen((state) async {
      if (!mounted) return;

      if (state is PremiumUnlocked) {
        Navigator.of(context).pop(true);
      } else if (state is PremiumError) {
        await IaculaModal.showAlert(
          context: context,
          title: 'Erro',
          message: state.message,
        );
      }
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  void _onAuthTransition(
    AsyncValue<dynamic>? previous,
    AsyncValue<dynamic> next,
  ) {
    final user = next.valueOrNull;
    if (user != null && _pendingPurchaseAfterSignIn) {
      _pendingPurchaseAfterSignIn = false;
      ref
          .read(premiumBlocProvider)
          .add(const PurchasePremium(productId: premiumLifetimeProductId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumStateProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isLoading = premiumState.valueOrNull is PremiumLoading;

    ref.listen(authStateProvider, _onAuthTransition);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Iacula Premium', style: IaculaText.sectionTitle),
                const SizedBox(height: 10),
              Text(
                'Acesso vitalício por R\$ 39,90.',
                style: IaculaText.secondary,
              ),
                const SizedBox(height: 20),
                _featureTile(CupertinoIcons.play_circle, 'Meditações'),
                _featureTile(
                  CupertinoIcons.check_mark_circled,
                  'Plano de vida',
                ),
                const SizedBox(height: 20),
                if (authUser == null) ...[
                  IaculaPrimaryPillButton(
                    label: isLoading ? 'Aguarde...' : 'Entrar para continuar',
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => _pendingPurchaseAfterSignIn = true);
                            await ref
                                .read(authRepositoryProvider)
                                .signInWithGoogle();
                          },
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  IaculaPrimaryPillButton(
                    label: isLoading
                        ? 'Aguarde...'
                        : 'Desbloquear por R\$ 39,90',
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(premiumBlocProvider)
                                .add(
                                  const PurchasePremium(
                                    productId: premiumLifetimeProductId,
                                  ),
                                );
                          },
                  ),
                  const SizedBox(height: 10),
                  IaculaSecondaryPillButton(
                    label: 'Restaurar compras',
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(premiumBlocProvider)
                                .add(const RestorePurchases());
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: IaculaColors.primaryButton),
          const SizedBox(width: 10),
          Text(
            label,
            style: IaculaText.secondary.copyWith(
              color: IaculaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
