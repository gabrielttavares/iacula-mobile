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
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(IaculaSpacing.md),
              children: [
                const _BrandMark(),
                const SizedBox(height: 56),
                const Text(
                  'Presença de Deus\nno cotidiano',
                  textAlign: TextAlign.center,
                  style: IaculaText.largeTitle,
                ),
                const SizedBox(height: IaculaSpacing.xs),
                const Text(
                  'Jaculatórias, liturgia e plano de vida para rezar no ritmo do seu dia.',
                  textAlign: TextAlign.center,
                  style: IaculaText.secondary,
                ),
                const SizedBox(height: IaculaSpacing.xl),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.book,
                        title: 'Liturgia diária',
                        subtitle: 'Acompanhe as orações de cada dia.',
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.check_mark_circled,
                        title: 'Plano de vida',
                        subtitle: 'Cultive constância com pequenos passos.',
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
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                            builder: (_) => const ShellScreen(),
                          ),
                        ),
                ),
                const SizedBox(height: IaculaSpacing.md),
                const Text(
                  'Iacula • presença de Deus no cotidiano',
                  textAlign: TextAlign.center,
                  style: IaculaText.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(CupertinoIcons.circle_grid_3x3_fill, size: 20),
        SizedBox(width: 8),
        Text(
          'Iacula',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: IaculaColors.textPrimary,
          ),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: const EdgeInsets.all(IaculaSpacing.md),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: IaculaColors.primaryButton),
          const SizedBox(height: IaculaSpacing.sm),
          Text(title, style: IaculaText.cardTitle),
          const SizedBox(height: 4),
          Text(subtitle, style: IaculaText.secondary),
        ],
      ),
    );
  }
}
