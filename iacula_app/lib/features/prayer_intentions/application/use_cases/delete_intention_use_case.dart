// lib/features/prayer_intentions/application/use_cases/delete_intention_use_case.dart

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class DeleteIntentionUseCase {
  const DeleteIntentionUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call(String id) async {
    await _repository.markDeleted(id, deletedAt: DateTime.now());
  }
}
