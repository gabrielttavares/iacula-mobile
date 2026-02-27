import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../auth/presentation/auth_action_sheet.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../domain/entities/settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _intervalController;
  late TextEditingController _laudesTimeController;
  late TextEditingController _vespersTimeController;
  late TextEditingController _complineTimeController;
  late TextEditingController _oraMediaTimeController;

  String _language = 'pt-br';
  bool _soundEnabled = true;
  double _soundVolume = 0.35;
  bool _laudesEnabled = false;
  bool _vespersEnabled = false;
  bool _complineEnabled = false;
  bool _oraMediaEnabled = false;
  bool _onboardingCompleted = false;

  bool _loading = true;
  bool _saving = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController();
    _laudesTimeController = TextEditingController();
    _vespersTimeController = TextEditingController();
    _complineTimeController = TextEditingController();
    _oraMediaTimeController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    _intervalController.text = settings.intervalMinutes.toString();
    _laudesTimeController.text = settings.laudesTime;
    _vespersTimeController.text = settings.vespersTime;
    _complineTimeController.text = settings.complineTime;
    _oraMediaTimeController.text = settings.oraMediaTime;

    _language = settings.language;
    _soundEnabled = settings.liturgyReminderSoundEnabled;
    _soundVolume = settings.liturgyReminderSoundVolume;
    _laudesEnabled = settings.laudesEnabled;
    _vespersEnabled = settings.vespersEnabled;
    _complineEnabled = settings.complineEnabled;
    _oraMediaEnabled = settings.oraMediaEnabled;
    _onboardingCompleted = settings.onboardingCompleted;

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _laudesTimeController.dispose();
    _vespersTimeController.dispose();
    _complineTimeController.dispose();
    _oraMediaTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          children: [
            const IaculaLargeTitle('Configurações'),
            const SizedBox(height: IaculaSpacing.lg),
            const IaculaSectionHeader(title: 'Dados da conta'),
            const SizedBox(height: IaculaSpacing.sm),
            IaculaSoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Intervalo (minutos)'),
                  IaculaTextInput(
                    controller: _intervalController,
                    placeholder: '1..60',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  _fieldLabel('Idioma'),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<String>(
                    groupValue: _language,
                    children: const {
                      'pt-br': Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('Portugues'),
                      ),
                      'en': Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('English'),
                      ),
                      'la': Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('Latin'),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() => _language = value);
                      }
                    },
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  _switchRow(
                    title: 'Som no lembrete liturgico',
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                  CupertinoSlider(
                    min: 0,
                    max: 1,
                    divisions: 20,
                    value: _soundVolume,
                    onChanged: _soundEnabled
                        ? (v) => setState(() => _soundVolume = v)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: IaculaSpacing.lg),
            const IaculaSectionHeader(title: 'Liturgia das Horas'),
            const SizedBox(height: IaculaSpacing.sm),
            IaculaSoftCard(
              child: Column(
                children: [
                  _moduleRow(
                    'Laudes',
                    _laudesEnabled,
                    (v) => setState(() => _laudesEnabled = v),
                    _laudesTimeController,
                  ),
                  _moduleRow(
                    'Vesperas',
                    _vespersEnabled,
                    (v) => setState(() => _vespersEnabled = v),
                    _vespersTimeController,
                  ),
                  _moduleRow(
                    'Completas',
                    _complineEnabled,
                    (v) => setState(() => _complineEnabled = v),
                    _complineTimeController,
                  ),
                  _moduleRow(
                    'Ora Media',
                    _oraMediaEnabled,
                    (v) => setState(() => _oraMediaEnabled = v),
                    _oraMediaTimeController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: IaculaSpacing.md),
            _buildAuthSyncSection(),
            if (_validationMessage != null) ...[
              const SizedBox(height: IaculaSpacing.md),
              IaculaInlineMessage(
                message: _validationMessage!,
                color: IaculaColors.error,
              ),
            ],
            const SizedBox(height: IaculaSpacing.lg),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(26),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: IaculaText.secondary),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: IaculaText.cardTitle)),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _moduleRow(
    String label,
    bool enabled,
    ValueChanged<bool> onChanged,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IaculaSpacing.md),
      child: Column(
        children: [
          _switchRow(title: label, value: enabled, onChanged: onChanged),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _fieldLabel('Horario (HH:MM)'),
          ),
          IaculaTimeInput(controller: controller),
        ],
      ),
    );
  }

  Widget _buildAuthSyncSection() {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final user = authState.valueOrNull;

    return AuthActionSheet(
      title: 'Sincronizacao opcional',
      subtitle:
          'Entre para sincronizar seus dados espirituais entre dispositivos.\nSincronizacao automatica quando online.',
      signedInEmail: user?.email,
      onGoogle: () => authRepo.signInWithGoogle(),
      onMicrosoft: () => authRepo.signInWithMicrosoft(),
      onApple: () => authRepo.signInWithApple(),
      onSignOut: () => authRepo.signOut(),
    );
  }

  Future<void> _save() async {
    setState(() => _validationMessage = null);
    final interval = int.tryParse(_intervalController.text);
    if (interval == null || interval < 1 || interval > 60) {
      setState(() => _validationMessage = 'Use 1..60 no intervalo.');
      return;
    }

    final timeControllers = [
      _laudesTimeController,
      _vespersTimeController,
      _complineTimeController,
      _oraMediaTimeController,
    ];

    for (final controller in timeControllers) {
      if (!_isValidTime(controller.text)) {
        setState(() => _validationMessage = 'Formato HH:MM');
        return;
      }
    }

    setState(() => _saving = true);

    final settings = Settings(
      intervalMinutes: interval,
      durationSeconds: Settings.defaults.durationSeconds,
      autostart: Settings.defaults.autostart,
      language: _language,
      liturgyReminderSoundEnabled: _soundEnabled,
      liturgyReminderSoundVolume: _soundVolume,
      laudesEnabled: _laudesEnabled,
      vespersEnabled: _vespersEnabled,
      complineEnabled: _complineEnabled,
      oraMediaEnabled: _oraMediaEnabled,
      laudesTime: _laudesTimeController.text,
      vespersTime: _vespersTimeController.text,
      complineTime: _complineTimeController.text,
      oraMediaTime: _oraMediaTimeController.text,
      onboardingCompleted: _onboardingCompleted,
    );

    await ref.read(updateSettingsUseCaseProvider).call(settings);

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    await schedulerRepo.cancelAll();
    await ScheduleCoreRemindersUseCase(
      schedulerRepo,
      quoteFetcher: ({required String language, required DateTime now}) {
        return ref
            .read(getNextQuoteUseCaseProvider)
            .call(language: language, now: now);
      },
      lastDeliveredCardRepository: ref.read(
        lastDeliveredCardRepositoryProvider,
      ),
    ).call(settings);
    await ScheduleLiturgyRemindersUseCase(schedulerRepo).call(settings);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }

  bool _isValidTime(String value) {
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(value);
  }
}
