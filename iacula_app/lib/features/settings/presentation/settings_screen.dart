import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/interval_selector.dart';
import '../../../core/presentation/widgets/keyboard_dismiss.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/presentation/custom_phrases_screen.dart';
import '../../home_widget/home_widget_service.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../domain/entities/settings.dart';
import '../domain/jaculatoria_interval.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'pt-br';
  bool _onboardingCompleted = false;
  String _themeMode = 'system';
  bool _notificationsEnabled = true;
  bool _angelusEnabled = true;
  int _intervalMinutes = 15;
  bool _permissionGranted = true;
  bool? _exactAlarmsReliable;
  bool _inexactScheduleFallbackUsed = false;
  bool _shortIntervalReliabilityNotGuaranteed = false;
  bool _escrivaPointsFeedOptionVisible = false;
  bool _liturgicalSeasonEnabled = false;
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';
  bool _customPhrasesOnly = false;

  bool _loading = true;
  bool _saving = false;
  String? _validationMessage;

  late Settings _loadedSettings;

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
    _angelusEnabled = settings.angelusEnabled;
    _intervalMinutes = clampJaculatoriaIntervalMinutes(
      settings.intervalMinutes,
    );
    _escrivaPointsFeedOptionVisible = settings.escrivaPointsFeedOptionVisible;
    _liturgicalSeasonEnabled = settings.liturgicalSeasonEnabled;
    _quietHoursEnabled = settings.quietHoursEnabled;
    _quietHoursStart = settings.quietHoursStart;
    _quietHoursEnd = settings.quietHoursEnd;
    _customPhrasesOnly = settings.customPhrasesOnly;

    final scheduler = ref.read(notificationSchedulerRepositoryProvider);
    if (scheduler is LocalNotificationSchedulerRepository) {
      _permissionGranted = await scheduler.checkPermission();
      final canExact = await scheduler.canScheduleExactNotifications();
      _exactAlarmsReliable = canExact ?? true;
      _inexactScheduleFallbackUsed = scheduler.usedInexactScheduleFallback;
      _shortIntervalReliabilityNotGuaranteed =
          settings.notificationsEnabled &&
          settings.intervalMinutes <= 15 &&
          (canExact == false);
    } else {
      _exactAlarmsReliable = true;
      _shortIntervalReliabilityNotGuaranteed = false;
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
                              ? _angelusEnabled
                                    ? 'Jaculatória ${formatJaculatoriaIntervalEveryPhrase(_intervalMinutes)} e Angelus ao meio-dia.'
                                    : 'Jaculatória ${formatJaculatoriaIntervalEveryPhrase(_intervalMinutes)}.'
                              : 'As notificações estão desativadas.',
                          style: context.textStyles.secondary,
                        ),
                        if (!_permissionGranted) ...[
                          const SizedBox(height: IaculaSpacing.sm),
                          _buildPermissionWarning(context),
                        ],
                        if (_notificationsEnabled &&
                            _intervalMinutes <= 15 &&
                            (_shortIntervalReliabilityNotGuaranteed ||
                                (_exactAlarmsReliable == false) ||
                                _inexactScheduleFallbackUsed)) ...[
                          const SizedBox(height: IaculaSpacing.sm),
                          _buildShortIntervalReliabilityWarning(context),
                        ],
                        if (_notificationsEnabled) ...[
                          const SizedBox(height: IaculaRadius.elementSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Angelus ao meio-dia',
                                  style: context.textStyles.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              CupertinoSwitch(
                                value: _angelusEnabled,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _angelusEnabled = value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: IaculaRadius.elementSpacing),
                          _fieldLabel(context, 'Intervalo entre jaculatórias'),
                          const SizedBox(height: 8),
                          IntervalSelector(
                            selectedMinutes: _intervalMinutes,
                            onChanged: (value) => setState(() => _intervalMinutes = value),
                            showCustomLabel: true,
                          ),
                          const SizedBox(height: IaculaSpacing.sm),
                          _buildNextNotificationEstimate(context),
                          const SizedBox(height: IaculaRadius.elementSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Horário silencioso',
                                  style: context.textStyles.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              CupertinoSwitch(
                                value: _quietHoursEnabled,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _quietHoursEnabled = value);
                                },
                              ),
                            ],
                          ),
                          if (_quietHoursEnabled) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Notificações pausadas das $_quietHoursStart às $_quietHoursEnd.',
                              style: context.textStyles.secondary,
                            ),
                            const SizedBox(height: IaculaSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuietTimeButton(
                                    context,
                                    label: 'Início',
                                    value: _quietHoursStart,
                                    onTap: () async {
                                      final selected = await _pickTime(
                                        _quietHoursStart,
                                      );
                                      if (selected != null) {
                                        setState(() {
                                          _quietHoursStart = selected;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: IaculaSpacing.sm),
                                Expanded(
                                  child: _buildQuietTimeButton(
                                    context,
                                    label: 'Fim',
                                    value: _quietHoursEnd,
                                    onTap: () async {
                                      final selected = await _pickTime(
                                        _quietHoursEnd,
                                      );
                                      if (selected != null) {
                                        setState(() {
                                          _quietHoursEnd = selected;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                            const Icon(
                              CupertinoIcons.textformat_size,
                              size: 14,
                            ),
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
                            const Icon(
                              CupertinoIcons.textformat_size,
                              size: 22,
                            ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IaculaRadius.innerPadding,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jaculatórias do tempo litúrgico',
                                      style: context.textStyles.cardTitle
                                          .copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _liturgicalSeasonEnabled
                                          ? 'As jaculatórias seguem o tempo litúrgico atual (Advento, Quaresma, Páscoa…).'
                                          : 'As jaculatórias seguem a ênfase do rito latino por dia da semana.',
                                      style: context.textStyles.secondary
                                          .copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CupertinoSwitch(
                                value: _liturgicalSeasonEnabled,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () => _liturgicalSeasonEnabled = value,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: context.colors.separator),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IaculaRadius.innerPadding,
                            vertical: 16,
                          ),
                          onPressed: () {
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
                        Container(height: 1, color: context.colors.separator),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IaculaRadius.innerPadding,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Usar apenas minhas frases',
                                      style: context.textStyles.cardTitle.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Exibe apenas suas frases personalizadas, ignorando as jaculatórias do tempo.',
                                      style: context.textStyles.secondary.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CupertinoSwitch(
                                value: _customPhrasesOnly,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _customPhrasesOnly = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: context.colors.separator),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IaculaRadius.innerPadding,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pontos de Caminho/Sulco/Forja',
                                      style: context.textStyles.cardTitle
                                          .copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Exibe em Minhas frases a opção de usar estes conteúdos no lugar das jaculatórias.',
                                      style: context.textStyles.secondary
                                          .copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CupertinoSwitch(
                                value: _escrivaPointsFeedOptionVisible,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () =>
                                        _escrivaPointsFeedOptionVisible = value,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

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
                bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
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

  Widget _buildShortIntervalReliabilityWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IaculaSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IaculaRadius.small),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.clock_fill,
            color: context.colors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Não é possível garantir intervalos curtos (por exemplo, 5 minutos) sem alarmes exatos no Android. '
              'Sem essa permissão, o sistema pode atrasar as jaculatórias. '
              'Abra as configurações do app e ative alarmes e lembretes exatos, se disponível. '
              'A atualização do widget em segundo plano também é em melhor esforço e pode atrasar dependendo do sistema.',
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

  Widget _buildQuietTimeButton(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: IaculaSpacing.sm,
        vertical: IaculaSpacing.xs,
      ),
      color: context.colors.card,
      borderRadius: BorderRadius.circular(IaculaRadius.small),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.secondary),
          Text(value, style: context.textStyles.cardTitle),
        ],
      ),
    );
  }

  Future<String?> _pickTime(String initialHHMM) async {
    var selected = initialHHMM;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        return Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(modalContext),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () => Navigator.of(modalContext).pop(),
                  child: const Text('Concluir'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: _timeToDateTime(initialHHMM),
                  onDateTimeChanged: (value) {
                    selected = _formatHHMM(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    return selected;
  }

  DateTime _timeToDateTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _formatHHMM(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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
      angelusEnabled: _angelusEnabled,
      escrivaPointsFeedOptionVisible: _escrivaPointsFeedOptionVisible,
      escrivaPointsFeedEnabled: _escrivaPointsFeedOptionVisible,
      liturgicalSeasonEnabled: _liturgicalSeasonEnabled,
      quietHoursEnabled: _quietHoursEnabled,
      quietHoursStart: _quietHoursStart,
      quietHoursEnd: _quietHoursEnd,
      customPhrasesOnly: _customPhrasesOnly,
    );

    await ref.read(updateSettingsUseCaseProvider).call(settings);
    ref.invalidate(getSettingsUseCaseProvider);
    await HomeWidgetService.instance.saveIntervalMinutes(_intervalMinutes);

    final season = await ref
        .read(liturgicalSeasonServiceProvider)
        .getCurrentSeason();
    final rebuildResult = await ref
        .read(rebuildNotificationsUseCaseProvider)
        .call(
          settings,
          isEasterSeason: season == LiturgicalSeason.easter,
          showImmediate: false,
        );

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    if (schedulerRepo is LocalNotificationSchedulerRepository) {
      final canExact = await schedulerRepo.canScheduleExactNotifications();
      if (mounted) {
        setState(() {
          _exactAlarmsReliable = canExact ?? true;
          _inexactScheduleFallbackUsed =
              schedulerRepo.usedInexactScheduleFallback;
          _shortIntervalReliabilityNotGuaranteed =
              rebuildResult.shortIntervalReliabilityNotGuaranteed;
        });
      }
    }

    ref.read(notificationPermissionProvider.notifier).state =
        _permissionGranted;

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }
}
