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
                  'Reze. Cresça. Persevere.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.sectionTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tudo para sua vida de oração, no ritmo do seu dia.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.secondary,
                ),
                const SizedBox(height: IaculaSpacing.xl),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.bell_fill,
                        title: 'Jaculatória Diária',
                        subtitle: 'Orações curtas ao longo do dia.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.book,
                        title: 'Liturgia Diária',
                        subtitle: 'Leituras e orações de cada dia.',
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
                        title: 'Rosário',
                        subtitle: 'Todos os mistérios para meditar.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.sparkles,
                        title: 'Meditação',
                        subtitle: 'Reflexões guiadas para o silêncio.',
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
                        title: 'Plano de Vida',
                        subtitle: 'Constância com pequenos passos.',
                        minHeight: 120,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.pencil_outline,
                        title: 'Exame Pessoal',
                        subtitle: 'Prepare-se para a confissão.',
                        minHeight: 120,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IaculaSpacing.xl),
                IaculaPrimaryPillButton(
                  label: _saving ? 'Entrando...' : 'Começar com sua conta',
                  onPressed: _saving ? null : _completeOnboarding,
                ),
                const SizedBox(height: IaculaSpacing.sm),
                IaculaSecondaryPillButton(
                  label: 'Começar sem conta',
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
