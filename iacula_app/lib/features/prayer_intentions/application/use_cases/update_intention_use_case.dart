// lib/features/prayer_intentions/application/use_cases/update_intention_use_case.dart

import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class UpdateIntentionUseCase {
  const UpdateIntentionUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call({
    required String id,
    required String title,
    String? description,
  }) async {
    final entries = await _repository.listLocal();
    final existing = entries.firstWhere((e) => e.id == id);
    final updated = existing.copyWith(
      title: title,
      body: description ?? '',
      updatedAt: DateTime.now(),
      isDirty: true,
    );
    await _repository.saveLocal(updated);
  }
}
