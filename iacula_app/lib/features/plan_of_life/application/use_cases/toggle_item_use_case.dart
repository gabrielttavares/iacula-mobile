import '../../domain/entities/daily_completion.dart';
import '../../domain/repositories/plan_completion_repository.dart';

class ToggleItemUseCase {
  const ToggleItemUseCase(this._completionRepository);

  final PlanCompletionRepository _completionRepository;

  Future<void> call({
    required String itemId,
    required DateTime date,
    required bool completed,
  }) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    if (completed) {
      await _completionRepository.saveCompletion(
        DailyCompletion(
          itemId: itemId,
          date: dateString,
          completedAt: DateTime.now(),
        ),
      );
    } else {
      await _completionRepository.deleteCompletion(itemId, dateString);
    }
  }
}
