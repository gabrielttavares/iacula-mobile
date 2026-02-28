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
                const _BrandBlock(),
                const SizedBox(height: IaculaSpacing.md),
                const Text(
                  'Jaculatórias, liturgia e plano de vida para rezar no ritmo do seu dia.',
                  textAlign: TextAlign.center,
                  style: IaculaText.secondary,
                ),
                const SizedBox(height: IaculaSpacing.xl),
                const _ExclusiveFeatureCard(),
                const SizedBox(height: IaculaSpacing.sm),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.book,
                        title: 'Liturgia Diária',
                        subtitle: 'Acompanhe as orações de cada dia.',
                        minHeight: 140,
                      ),
                    ),
                    SizedBox(width: IaculaSpacing.sm),
                    Expanded(
                      child: _FeatureCard(
                        icon: CupertinoIcons.check_mark_circled,
                        title: 'Plano de Vida',
                        subtitle: 'Cultive constância com pequenos passos.',
                        minHeight: 140,
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
            style: IaculaText.largeTitle,
          ),
      ],
    );
  }
}

class _ExclusiveFeatureCard extends StatelessWidget {
  const _ExclusiveFeatureCard();

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      padding: const EdgeInsets.all(IaculaSpacing.md),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(CupertinoIcons.bell_fill, color: IaculaColors.primaryButton),
              const Text(
                'EXCLUSIVO',
                style: TextStyle(
                  color: IaculaColors.primaryButton,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: IaculaSpacing.sm),
          Text(
            'Notificações diárias com Jaculatórias',
            style: IaculaText.cardTitle,
          ),
          const SizedBox(height: 4),
          const Text(
            'Angelus / Regina Caeli às 12:00 PM',
            style: IaculaText.secondary,
          ),
        ],
      ),
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
            Icon(icon, color: IaculaColors.primaryButton),
            const SizedBox(height: IaculaSpacing.sm),
            Text(title, style: IaculaText.cardTitle),
            const SizedBox(height: 4),
            Text(subtitle, style: IaculaText.secondary),
          ],
        ),
      ),
    );
  }
}
