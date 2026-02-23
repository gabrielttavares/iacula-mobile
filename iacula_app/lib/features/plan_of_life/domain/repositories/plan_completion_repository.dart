import '../entities/daily_completion.dart';

abstract class PlanCompletionRepository {
  Future<List<DailyCompletion>> getCompletionsForDate(String date);
  Future<void> saveCompletion(DailyCompletion completion);
  Future<void> deleteCompletion(String itemId, String date);
}
