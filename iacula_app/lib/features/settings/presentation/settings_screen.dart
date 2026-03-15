import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/keyboard_dismiss.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/presentation/auth_action_sheet.dart';
import '../../custom_phrases/presentation/custom_phrases_screen.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../../notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../domain/entities/settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'pt-br';
  bool _onboardingCompleted = false;
  String _themeMode = 'dark';
  bool _notificationsEnabled = true;
  int _intervalMinutes = 15;
  bool _permissionGranted = true;

  bool _loading = true;
  bool _saving = false;
  String? _validationMessage;

  late Settings _loadedSettings;

  static const _intervalOptions = [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    _loadedSettings = settings;
    _language = settings.language;
    _onboardingCompleted = settings.onboardingCompleted;
    _themeMode = settings.themeMode;
    _notificationsEnabled = settings.notificationsEnabled;
    _intervalMinutes = settings.intervalMinutes;

    final scheduler = ref.read(notificationSchedulerRepositoryProvider);
    if (scheduler is LocalNotificationSchedulerRepository) {
      _permissionGranted = await scheduler.checkPermission();
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: IaculaKeyboardDismiss(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Configurações'),
              backgroundColor: context.colors.background,
              border: null,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // -- NOTIFICAÇÕES --
                  const IaculaSectionHeader(title: 'Notificações'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Notificações ativas',
                                style: context.textStyles.cardTitle.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              value: _notificationsEnabled,
                              activeTrackColor: context.colors.primaryButton,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                setState(() => _notificationsEnabled = value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _notificationsEnabled
                              ? 'Você recebe uma jaculatória a cada $_intervalMinutes minutos.'
                              : 'As notificações estão desativadas.',
                          style: context.textStyles.secondary,
                        ),
                        if (!_permissionGranted) ...[
                          const SizedBox(height: IaculaSpacing.sm),
                          _buildPermissionWarning(context),
                        ],
                        if (_notificationsEnabled) ...[
                          const SizedBox(height: IaculaRadius.elementSpacing),
                          _fieldLabel(context, 'Intervalo (minutos)'),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoSlidingSegmentedControl<int>(
                              groupValue: _intervalOptions.contains(
                                      _intervalMinutes)
                                  ? _intervalMinutes
                                  : 15,
                              padding: const EdgeInsets.all(4),
                              children: {
                                for (final opt in _intervalOptions)
                                  opt: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    child: Text('$opt'),
                                  ),
                              },
                              onValueChanged: (value) {
                                if (value != null) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _intervalMinutes = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: IaculaSpacing.sm),
                          _buildNextNotificationEstimate(context),
                        ],
                      ],
                    ),
                  ),

                  // -- APARÊNCIA --
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Aparência'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(context, 'Tema'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _themeMode,
                            padding: const EdgeInsets.all(4),
                            children: const {
                              'light': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Claro'),
                              ),
                              'dark': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Escuro'),
                              ),
                              'system': Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text('Sistema'),
                              ),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                HapticFeedback.selectionClick();
                                setState(() => _themeMode = value);
                                ref.read(themeModeProvider.notifier).state =
                                    value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: IaculaRadius.elementSpacing),
                        _fieldLabel(context, 'Tamanho da fonte'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.textformat_size,
                                size: 14),
                            Expanded(
                              child: CupertinoSlider(
                                value: _loadedSettings.prayerFontSize,
                                min: 12,
                                max: 24,
                                divisions: 12,
                                activeColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  setState(() {
                                    _loadedSettings = _loadedSettings.copyWith(
                                      prayerFontSize: value,
                                    );
                                  });
                                },
                              ),
                            ),
                            const Icon(CupertinoIcons.textformat_size,
                                size: 22),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.colors.separator,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Pelo sinal da santa cruz, livrai-nos, Deus, nosso Senhor, dos nossos inimigos.',
                            textAlign: TextAlign.center,
                            style: context.textStyles.readingBody.copyWith(
                              fontSize: _loadedSettings.prayerFontSize,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -- PERSONALIZAÇÃO --
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Personalização'),
                  const SizedBox(height: IaculaSpacing.sm),
                  IaculaSoftCard(
                    padding: EdgeInsets.zero,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IaculaRadius.innerPadding,
                        vertical: 16,
                      ),
                      onPressed: () {
                        final isPremium =
                            ref
                                .read(premiumStatusProvider)
                                .valueOrNull
                                ?.isPremium ??
                            true;
                        if (!isPremium) {
                          PremiumGate.showModal(
                            context,
                            feature: PremiumFeature.meditation,
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const CustomPhrasesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Minhas frases',
                            style: context.textStyles.cardTitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: context.colors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // -- CONTA --
                  const SizedBox(height: IaculaRadius.cardSpacing),
                  const IaculaSectionHeader(title: 'Conta'),
                  const SizedBox(height: IaculaSpacing.sm),
                  _buildAuthSyncSection(),

                  if (_validationMessage != null) ...[
                    const SizedBox(height: IaculaSpacing.md),
                    IaculaInlineMessage(
                      message: _validationMessage!,
                      color: context.colors.error,
                    ),
                  ],

                  const SizedBox(height: IaculaSpacing.lg),
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(26),
                    onPressed: _saving
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            _save();
                          },
                    child: Text(_saving ? 'Salvando...' : 'Salvar'),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: context.textStyles.secondary),
    );
  }

  Widget _buildPermissionWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IaculaSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IaculaRadius.small),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: context.colors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Permissão de notificação negada. Ative nas Configurações do sistema.',
              style: context.textStyles.secondary.copyWith(
                color: context.colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextNotificationEstimate(BuildContext context) {
    final nextAt = DateTime.now().add(Duration(minutes: _intervalMinutes));
    final hh = nextAt.hour.toString().padLeft(2, '0');
    final mm = nextAt.minute.toString().padLeft(2, '0');

    return Row(
      children: [
        Icon(
          CupertinoIcons.clock,
          size: 14,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          'Próxima estimada: $hh:$mm',
          style: context.textStyles.secondary.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAuthSyncSection() {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final user = authState.valueOrNull;

    return AuthActionSheet(
      title: 'Sincronização entre dispositivos',
      subtitle:
          'Faça login para manter seus dados espirituais sincronizados entre dispositivos. A sincronização acontece automaticamente.',
      signedInEmail: user?.email,
      onGoogle: () => authRepo.signInWithGoogle(),
      onMicrosoft: () => authRepo.signInWithMicrosoft(),
      onApple: () => authRepo.signInWithApple(),
      onSignOut: () => authRepo.signOut(),
    );
  }

  Future<void> _save() async {
    setState(() {
      _validationMessage = null;
      _saving = true;
    });

    final settings = _loadedSettings.copyWith(
      intervalMinutes: _intervalMinutes,
      language: _language,
      onboardingCompleted: _onboardingCompleted,
      themeMode: _themeMode,
      notificationsEnabled: _notificationsEnabled,
    );

    await ref.read(updateSettingsUseCaseProvider).call(settings);

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    await schedulerRepo.cancelAll();

    if (_notificationsEnabled) {
      await ScheduleCoreRemindersUseCase(
        schedulerRepo,
        quoteFetcher: ({required String language, required DateTime now}) {
          if (settings.escrivaPointsFeedEnabled) {
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
      ).call(settings);
      await ScheduleLiturgyRemindersUseCase(schedulerRepo).call(settings);
    }

    ref.read(notificationPermissionProvider.notifier).state =
        _permissionGranted;

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }
}
