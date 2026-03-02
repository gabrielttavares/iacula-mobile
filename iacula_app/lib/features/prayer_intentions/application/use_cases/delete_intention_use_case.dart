// lib/features/prayer_intentions/application/use_cases/delete_intention_use_case.dart

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import 'cancel_prayer_intention_reminder_use_case.dart';

final class DeleteIntentionUseCase {
  const DeleteIntentionUseCase(
    this._repository,
    this._cancelReminder,
  );

  final SpiritualEntryRepository _repository;
  final CancelPrayerIntentionReminderUseCase _cancelReminder;

  Future<void> call(String id) async {
    await _cancelReminder(id);
    await _repository.markDeleted(id, deletedAt: DateTime.now());
  }
}
