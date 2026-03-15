import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/shell_screen.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _saving = false;
  int _selectedInterval = 15;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  _WelcomePage(
                    onContinue: () => _goToPage(1),
                  ),
                  _NotificationSetupPage(
                    selectedInterval: _selectedInterval,
                    onIntervalChanged: (v) =>
                        setState(() => _selectedInterval = v),
                    saving: _saving,
                    onComplete: _completeWithNotifications,
                    onSkip: _skipWithoutAccount,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? context.colors.primaryButton
                          : context.colors.separator,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeWithNotifications() async {
    setState(() => _saving = true);

    final scheduler = ref.read(notificationSchedulerRepositoryProvider);
    if (scheduler is LocalNotificationSchedulerRepository) {
      final granted = await scheduler.requestPermission();
      ref.read(notificationPermissionProvider.notifier).state = granted;
    }

    final settings = await ref.read(getSettingsUseCaseProvider).call();
    final updated = settings.copyWith(
      onboardingCompleted: true,
      intervalMinutes: _selectedInterval,
      notificationsEnabled: true,
    );
    await ref.read(updateSettingsUseCaseProvider).call(updated);

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    await schedulerRepo.cancelAll();
    await ScheduleCoreRemindersUseCase(
      schedulerRepo,
      quoteFetcher: ({required String language, required DateTime now}) {
        if (updated.escrivaPointsFeedEnabled) {
          return ref
              .read(getNextEscrivaPointsQuoteUseCaseProvider)
              .call(language: language, now: now);
        }
        return ref
            .read(getNextQuoteUseCaseProvider)
            .call(language: language, now: now);
      },
      lastDeliveredCardRepository: ref.read(
        lastDeliveredCardRepositoryProvider,
      ),
    ).call(updated);
    await ScheduleLiturgyRemindersUseCase(schedulerRepo).call(updated);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const ShellScreen()),
    );
  }

  Future<void> _skipWithoutAccount() async {
    setState(() => _saving = true);
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    await ref
        .read(updateSettingsUseCaseProvider)
        .call(settings.copyWith(
          onboardingCompleted: true,
          intervalMinutes: _selectedInterval,
        ));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const ShellScreen()),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              'Volte a Deus ao longo do dia.',
              textAlign: TextAlign.center,
              style: context.textStyles.sectionTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'Um caminho simples de oração, leitura e exame para recomeçar com constância.',
              textAlign: TextAlign.center,
              style: context.textStyles.secondary,
            ),
            const SizedBox(height: IaculaSpacing.xl),
            const _FeatureCard(
              icon: CupertinoIcons.bell_fill,
              title: 'Reze sem se perder',
              subtitle:
                  'Encontre rápido o melhor ponto de partida para agora.',
              minHeight: 104,
            ),
            const SizedBox(height: IaculaSpacing.sm),
            const _FeatureCard(
              icon: CupertinoIcons.arrow_clockwise_circle,
              title: 'Volte rápido ao essencial',
              subtitle:
                  'Jaculatórias, leituras e meditações para retomar o recolhimento.',
              minHeight: 104,
            ),
            const SizedBox(height: IaculaSpacing.sm),
            const _FeatureCard(
              icon: CupertinoIcons.check_mark_circled,
              title: 'Siga um ritmo de oração',
              subtitle:
                  'Liturgia, exame e práticas diárias para perseverar com paz.',
              minHeight: 104,
            ),
            const SizedBox(height: IaculaSpacing.xl),
            IaculaPrimaryPillButton(
              label: 'Continuar',
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSetupPage extends StatelessWidget {
  const _NotificationSetupPage({
    required this.selectedInterval,
    required this.onIntervalChanged,
    required this.saving,
    required this.onComplete,
    required this.onSkip,
  });

  final int selectedInterval;
  final ValueChanged<int> onIntervalChanged;
  final bool saving;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  static const _intervalOptions = [5, 10, 15, 30, 60];

  String _intervalDescription(int minutes) {
    if (minutes < 60) return 'a cada $minutes minutos';
    return 'a cada hora';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.xl,
            IaculaSpacing.md,
            IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Icon(
              CupertinoIcons.bell_fill,
              size: 48,
              color: context.colors.primaryButton,
            ),
            const SizedBox(height: IaculaSpacing.md),
            Text(
              'Jaculatórias no seu dia',
              textAlign: TextAlign.center,
              style: context.textStyles.sectionTitle,
            ),
            const SizedBox(height: IaculaSpacing.sm),
            Text(
              'O Iacula te envia uma breve oração via notificação, '
              'para você voltar a Deus durante o dia sem interromper o que está fazendo.',
              textAlign: TextAlign.center,
              style: context.textStyles.secondary,
            ),
            const SizedBox(height: IaculaSpacing.xl),

            IaculaSoftCard(
              child: Column(
                children: [
                  Text(
                    'Com que frequência?',
                    style: context.textStyles.cardTitle,
                  ),
                  const SizedBox(height: IaculaSpacing.sm),
                  Text(
                    'Você vai receber uma notificação ${_intervalDescription(selectedInterval)} com uma jaculatória diferente.',
                    textAlign: TextAlign.center,
                    style: context.textStyles.secondary,
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: selectedInterval,
                      padding: const EdgeInsets.all(4),
                      children: {
                        for (final opt in _intervalOptions)
                          opt: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            child: Text(
                              opt < 60 ? '${opt}m' : '1h',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          HapticFeedback.selectionClick();
                          onIntervalChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: IaculaSpacing.md),

            // Preview card
            IaculaSoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.app_badge,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Iacula',
                        style: context.textStyles.cardTitle.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'agora',
                        style: context.textStyles.secondary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Senhor, aumenta a minha fé."',
                    style: context.textStyles.secondary.copyWith(
                      color: context.colors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: IaculaSpacing.xl),
            IaculaPrimaryPillButton(
              label: saving ? 'Configurando...' : 'Ativar notificações',
              onPressed: saving ? null : onComplete,
            ),
            const SizedBox(height: IaculaSpacing.sm),
            IaculaSecondaryPillButton(
              label: 'Agora não',
              onPressed: saving ? null : onSkip,
            ),
          ],
        ),
      ),
    );
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
