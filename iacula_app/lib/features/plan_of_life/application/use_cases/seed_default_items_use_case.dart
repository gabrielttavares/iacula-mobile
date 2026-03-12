import 'package:uuid/uuid.dart';

import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/plan_item_schedule.dart';

class SeedDefaultItemsUseCase {
  const SeedDefaultItemsUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call() async {
    final existing = await _repository.listLocal();
    if (existing.isNotEmpty) {
      return; // Already seeded or user has items
    }

    final now = DateTime.now();

    final defaults = [
      _createDefaultEntry('Oferecimento de obras', '07:00', now),
      _createDefaultEntry('Leitura do Santo Evangelho', '08:00', now),
      _createDefaultEntry('Leitura espiritual', '09:00', now),
      _createDefaultEntry('Angelus (Anjo do Senhor)', '12:00', now),
      _createDefaultEntry('Oração mental (ou meditação)', '15:00', now),
      _createDefaultEntry('Visita ao Santíssimo', '16:00', now),
      _createDefaultEntry('Terço', '18:00', now),
      _createDefaultEntry('Santa Missa', '19:00', now),
      _createDefaultEntry('3 Ave-Marias antes de deitar', '22:00', now),
      _createDefaultEntry('Exame Diário', '22:15', now),
    ];

    await _repository.upsertMany(defaults);
  }

  SpiritualEntry _createDefaultEntry(String title, String time, DateTime now) {
    final schedule = PlanItemSchedule(
      time: time,
      daysOfWeek: [], // Every day
      notify: false,
      isDefault: true,
    );

    return SpiritualEntry(
      id: const Uuid().v4(),
      module: SpiritualModule.planOfLife,
      title: title,
      body: '',
      scheduleJson: schedule.toJson(),
      createdAt: now,
      updatedAt: now,
      isDirty: true,
    );
  }
}
