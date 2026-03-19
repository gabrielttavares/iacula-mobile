import '../entities/notification_history_entry.dart';

abstract interface class NotificationHistoryRepository {
  Future<void> add(NotificationHistoryEntry entry);
  Future<void> clearFrom(DateTime instant);
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day);
}
