import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/plan_item.dart';
import '../../domain/repositories/plan_completion_repository.dart';

class GetDailyPlanUseCase {
  const GetDailyPlanUseCase(this._spiritualEntryRepository, this._completionRepository);

  final SpiritualEntryRepository _spiritualEntryRepository;
  final PlanCompletionRepository _completionRepository;

  Future<List<PlanItem>> call(DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    // Load all items including deleted to show historical snapshots
    final allEntries = await _spiritualEntryRepository.listLocal(includeDeleted: true);
    final completions = await _completionRepository.getCompletionsForDate(dateString);
    
    final completedItemIds = {
      for (final completion in completions) completion.itemId: completion.completedAt,
    };

    // Filter entries to only show items that existed on the selected date:
    // - createdAt <= selected date
    // - deletedAt is null OR deletedAt > selected date
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final entries = allEntries.where((entry) {
      if (entry.createdAt.isAfter(endOfDay)) return false;
      if (entry.deletedAt != null && entry.deletedAt!.isBefore(date)) return false;
      return true;
    }).toList();

    final items = entries.map((entry) {
      return PlanItem.fromSpiritualEntry(
        entry,
        completedAt: completedItemIds[entry.id],
      );
    }).toList();

    // Filter by day of week
    // DateTime weekday: 1 = Monday, 7 = Sunday
    final weekday = date.weekday;
    
    final filtered = items.where((item) {
      if (item.schedule.daysOfWeek.isEmpty) return true; // Empty means every day
      return item.schedule.daysOfWeek.contains(weekday);
    }).toList();

    // Sort by creation or time (time string "HH:mm")
    filtered.sort((a, b) {
      if (a.schedule.time != null && b.schedule.time != null) {
        return a.schedule.time!.compareTo(b.schedule.time!);
      }
      if (a.schedule.time != null) return -1;
      if (b.schedule.time != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return filtered;
  }
}
