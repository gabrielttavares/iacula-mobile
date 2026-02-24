import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/premium/application/premium_bloc.dart';

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
    _stateSub = bloc.states.listen((state) {
      if (!mounted) {
        return;
      }

      if (state is PremiumUnlocked) {
        Navigator.of(context).pop(true);
      } else if (state is PremiumError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message)));
      }
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  void _onAuthTransition(AsyncValue<dynamic>? previous, AsyncValue<dynamic> next) {
    final user = next.valueOrNull;
    if (user != null && _pendingPurchaseAfterSignIn) {
      _pendingPurchaseAfterSignIn = false;
      ref.read(premiumBlocProvider).add(
        const PurchasePremium(productId: premiumLifetimeProductId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumStateProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isLoading = premiumState.valueOrNull is PremiumLoading;

    ref.listen(authStateProvider, _onAuthTransition);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Desbloqueie o Premium',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Acesso vitalicio por R\$ 39,90.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                _featureTile(
                  context,
                  Icons.play_circle_outline,
                  'Meditacao diaria',
                ),
                _featureTile(context, Icons.checklist, 'Plano de Vida'),
                _featureTile(
                  context,
                  Icons.tune_rounded,
                  'Configuracoes premium',
                ),
                const SizedBox(height: 20),
                if (authUser == null) ...[
                  _GoogleSignInButton(
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() => _pendingPurchaseAfterSignIn = true);
                      await ref
                          .read(authRepositoryProvider)
                          .signInWithGoogle();
                    },
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  ElevatedButton(
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
                    child: Text(
                      isLoading
                          ? 'Processando...'
                          : 'Comprar por R\$ 29,90',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(premiumBlocProvider)
                                .add(const RestorePurchases());
                          },
                    child: const Text('Restaurar compras'),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureTile(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(isLoading ? 'Processando...' : 'Entrar para comprar'),
    );
  }
}
