import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/shell_screen.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                const _BrandBlock(),
                const SizedBox(height: IaculaSpacing.md),
                Text(
                  'Reze com constância em cada momento do dia.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.sectionTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Orações, leituras e meditações para ajudar você a voltar a Deus ao longo do dia.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.secondary,
                ),
                const SizedBox(height: IaculaSpacing.xl),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.bell_fill,
                        title: 'Jaculatórias do dia',
                        subtitle: 'Pequenas orações para recolher o coração.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.book,
                        title: 'Liturgia de hoje',
                        subtitle: 'Leituras e orações para acompanhar a Igreja.',
                        minHeight: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IaculaSpacing.sm),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.rosette,
                        title: 'Rosário guiado',
                        subtitle: 'Mistérios e textos para rezar com calma.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.sparkles,
                        title: 'Meditação',
                        subtitle: 'Caminhos de recolhimento para rezar melhor.',
                        minHeight: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IaculaSpacing.sm),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.check_mark_circled,
                        title: 'Plano de vida',
                        subtitle: 'Fidelidade nas pequenas práticas de cada dia.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.pencil_outline,
                        title: 'Exame de consciência',
                        subtitle: 'Prepare a confissão com serenidade.',
                        minHeight: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IaculaSpacing.xl),
                IaculaPrimaryPillButton(
                  label: _saving ? 'Entrando...' : 'Entrar e começar',
                  onPressed: _saving ? null : _completeOnboarding,
                ),
                const SizedBox(height: IaculaSpacing.sm),
                IaculaSecondaryPillButton(
                  label: 'Continuar sem conta',
                  onPressed: _saving ? null : _skipWithoutAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _skipWithoutAccount() async {
    setState(() => _saving = true);
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    await ref
        .read(updateSettingsUseCaseProvider)
        .call(settings.copyWith(onboardingCompleted: true));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const ShellScreen()),
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _saving = true);
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    await ref
        .read(updateSettingsUseCaseProvider)
        .call(settings.copyWith(onboardingCompleted: true));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(CupertinoPageRoute(builder: (_) => const ShellScreen()));
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/seed/images/icon.png',
          width: 94,
          height: 94,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(CupertinoIcons.circle, size: 94),
        ),
        const SizedBox(height: IaculaSpacing.sm),
          Text(
            'Iacula',
            textAlign: TextAlign.center,
            style: context.textStyles.largeTitle,
          ),
      ],
    );
  }
}


class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.minHeight = 132,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: const EdgeInsets.all(IaculaSpacing.md),
      radius: 16,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.primaryButton),
            const SizedBox(height: IaculaSpacing.sm),
            Text(title, style: context.textStyles.cardTitle),
            const SizedBox(height: 4),
            Text(subtitle, style: context.textStyles.secondary),
          ],
        ),
      ),
    );
  }
}
