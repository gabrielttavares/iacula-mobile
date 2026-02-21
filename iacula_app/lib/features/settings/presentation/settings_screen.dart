import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../domain/entities/settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _intervalController;
  late TextEditingController _durationController;
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

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController();
    _durationController = TextEditingController();
    _laudesTimeController = TextEditingController();
    _vespersTimeController = TextEditingController();
    _complineTimeController = TextEditingController();
    _oraMediaTimeController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    _apply(settings);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _apply(Settings settings) {
    _intervalController.text = settings.intervalMinutes.toString();
    _durationController.text = settings.durationSeconds.toString();
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
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _durationController.dispose();
    _laudesTimeController.dispose();
    _vespersTimeController.dispose();
    _complineTimeController.dispose();
    _oraMediaTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Intervalo (minutos)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1 || n > 60) return 'Use 1..60';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duracao (segundos)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 5 || n > 30) return 'Use 5..30';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Idioma'),
              items: const [
                DropdownMenuItem(value: 'pt-br', child: Text('Portugues')), 
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'la', child: Text('Latin')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'pt-br'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _soundEnabled,
              title: const Text('Som no lembrete liturgico'),
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
            Slider(
              min: 0,
              max: 1,
              divisions: 20,
              value: _soundVolume,
              label: (_soundVolume * 100).round().toString(),
              onChanged: _soundEnabled ? (v) => setState(() => _soundVolume = v) : null,
            ),
            const SizedBox(height: 12),
            _moduleRow('Laudes', _laudesEnabled, (v) => setState(() => _laudesEnabled = v), _laudesTimeController),
            _moduleRow('Vesperas', _vespersEnabled, (v) => setState(() => _vespersEnabled = v), _vespersTimeController),
            _moduleRow('Completas', _complineEnabled, (v) => setState(() => _complineEnabled = v), _complineTimeController),
            _moduleRow('Ora Media', _oraMediaEnabled, (v) => setState(() => _oraMediaEnabled = v), _oraMediaTimeController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleRow(
    String label,
    bool enabled,
    ValueChanged<bool> onChanged,
    TextEditingController controller,
  ) {
    return Column(
      children: [
        SwitchListTile(
          value: enabled,
          title: Text(label),
          onChanged: onChanged,
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Horario (HH:MM)'),
          validator: (v) {
            final value = v ?? '';
            final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
            if (!regex.hasMatch(value)) return 'Formato HH:MM';
            return null;
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final settings = Settings(
      intervalMinutes: int.parse(_intervalController.text),
      durationSeconds: int.parse(_durationController.text),
      autostart: true,
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
    );

    await ref.read(updateSettingsUseCaseProvider).call(settings);

    final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
    await schedulerRepo.cancelAll();
    await ScheduleCoreRemindersUseCase(schedulerRepo).call(settings);
    await ScheduleLiturgyRemindersUseCase(schedulerRepo).call(settings);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuracoes salvas')));
      Navigator.of(context).pop(true);
    }
  }
}

