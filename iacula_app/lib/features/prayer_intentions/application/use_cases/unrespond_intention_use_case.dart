// lib/features/prayer_intentions/application/use_cases/unrespond_intention_use_case.dart

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class UnrespondIntentionUseCase {
  const UnrespondIntentionUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call(String id) async {
    final entries = await _repository.listLocal();
    final existing = entries.firstWhere((e) => e.id == id);
    final now = DateTime.now();
    final updated = existing.copyWith(
      clearRespondedAt: true,
      updatedAt: now,
      isDirty: true,
    );
    await _repository.saveLocal(updated);
  }
}
