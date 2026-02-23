import 'package:uuid/uuid.dart';

import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/plan_item_schedule.dart';

class AddPlanItemUseCase {
  const AddPlanItemUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call({
    required String title,
    required PlanItemSchedule schedule,
  }) async {
    final entry = SpiritualEntry(
      id: const Uuid().v4(),
      module: SpiritualModule.planOfLife,
      title: title,
      body: '',
      scheduleJson: schedule.toJson(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    await _repository.saveLocal(entry);
  }
}
