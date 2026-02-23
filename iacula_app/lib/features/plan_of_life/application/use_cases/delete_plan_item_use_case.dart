import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

class DeletePlanItemUseCase {
  const DeletePlanItemUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<void> call(String itemId) async {
    await _repository.markDeleted(itemId, deletedAt: DateTime.now());
  }
}
