import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../application/premium_bloc.dart';
import '../domain/entities/premium_feature.dart';
import 'premium_copy.dart';

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
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Text('Iacula Premium', style: context.textStyles.sectionTitle),
                const SizedBox(height: 10),
                Text(
                  'Um único pagamento para rezar com mais profundidade todos os dias.',
                  style: context.textStyles.secondary,
                ),
                const SizedBox(height: 20),
                _featureTile(
                  context,
                  CupertinoIcons.play_circle,
                  premiumCopyFor(PremiumFeature.meditation).featureTitle,
                  premiumCopyFor(PremiumFeature.meditation).gateMessage,
                ),
                _featureTile(
                  context,
                  CupertinoIcons.check_mark_circled,
                  premiumCopyFor(PremiumFeature.planOfLife).featureTitle,
                  premiumCopyFor(PremiumFeature.planOfLife).gateMessage,
                ),
                _featureTile(
                  context,
                  CupertinoIcons.book,
                  premiumCopyFor(PremiumFeature.leituras).featureTitle,
                  premiumCopyFor(PremiumFeature.leituras).gateMessage,
                ),
                const SizedBox(height: 20),
                if (authUser == null) ...[
                  IaculaPrimaryPillButton(
                    label: isLoading
                        ? 'Aguarde...'
                        : 'Entrar para liberar o Premium',
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
                        : 'Liberar Premium por R\$ 39,90',
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

  Widget _featureTile(
    BuildContext context,
    IconData icon,
    String label,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.primaryButton),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.secondary.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: context.textStyles.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
