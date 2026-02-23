import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/plan_item_schedule.dart';

class UpdatePlanItemUseCase {
  const UpdatePlanItemUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call({
    required String itemId,
    required String title,
    required PlanItemSchedule schedule,
  }) async {
    final entries = await _repository.listLocal();
    final entry = entries.where((e) => e.id == itemId).firstOrNull;
    
    if (entry == null) return;

    final updated = entry.copyWith(
      title: title,
      scheduleJson: schedule.toJson(),
      updatedAt: DateTime.now(),
      isDirty: true,
    );

    await _repository.saveLocal(updated);
  }
}
