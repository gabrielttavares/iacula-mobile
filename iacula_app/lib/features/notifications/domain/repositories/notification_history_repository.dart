import '../entities/notification_history_entry.dart';

abstract interface class NotificationHistoryRepository {
  Future<void> add(NotificationHistoryEntry entry);
  Future<void> clearFrom(DateTime instant);
  Future<void> clearFromExcept(DateTime instant, Set<String> keepTimestamps);
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day);
  Future<List<NotificationHistoryEntry>> listFromUntilEndOfDay(DateTime instant);
}
