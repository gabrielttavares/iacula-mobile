// lib/features/prayer_intentions/application/use_cases/respond_intention_use_case.dart

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class RespondIntentionUseCase {
  const RespondIntentionUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call(String id) async {
    final entries = await _repository.listLocal();
    final existing = entries.firstWhere((e) => e.id == id);
    final now = DateTime.now();
    final updated = existing.copyWith(
      respondedAt: now,
      updatedAt: now,
      isDirty: true,
    );
    await _repository.saveLocal(updated);
  }
}
