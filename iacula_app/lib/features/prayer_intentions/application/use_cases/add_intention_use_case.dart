// lib/features/prayer_intentions/application/use_cases/add_intention_use_case.dart

import 'package:uuid/uuid.dart';

import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class AddIntentionUseCase {
  const AddIntentionUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call({required String title, String? description}) async {
    final now = DateTime.now();
    final entry = SpiritualEntry(
      id: const Uuid().v4(),
      module: SpiritualModule.prayerIntention,
      title: title,
      body: description ?? '',
      createdAt: now,
      updatedAt: now,
      isDirty: true,
    );
    await _repository.saveLocal(entry);
  }
}
