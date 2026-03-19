import '../../domain/entities/notification_history_entry.dart';
import '../../domain/repositories/notification_history_repository.dart';

final class InMemoryNotificationHistoryRepository
    implements NotificationHistoryRepository {
  final List<NotificationHistoryEntry> _entries = [];

  @override
  Future<void> add(NotificationHistoryEntry entry) async {
    final alreadyExists = _entries.any(
      (current) =>
          current.quoteText == entry.quoteText &&
          current.deliveredAt == entry.deliveredAt,
    );
    if (alreadyExists) return;
    _entries.add(entry);
  }

  @override
  Future<void> clearFrom(DateTime instant) async {
    _entries.removeWhere(
      (entry) =>
          entry.deliveredAt.year == instant.year &&
          entry.deliveredAt.month == instant.month &&
          entry.deliveredAt.day == instant.day &&
          !entry.deliveredAt.isBefore(instant),
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final entries = _entries
        .where(
          (entry) =>
              !entry.deliveredAt.isBefore(start) && entry.deliveredAt.isBefore(end),
        )
        .toList(growable: false)
      ..sort((a, b) => b.deliveredAt.compareTo(a.deliveredAt));

    return entries;
  }
}
