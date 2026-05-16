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
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    _entries.removeWhere(
      (entry) =>
          entry.deliveredAt.isAfter(instant) && entry.deliveredAt.isBefore(end),
    );
  }

  @override
  Future<void> clearFromExcept(
    DateTime instant,
    Set<String> keepTimestamps,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    _entries.removeWhere(
      (entry) =>
          entry.deliveredAt.isAfter(instant) &&
          entry.deliveredAt.isBefore(end) &&
          !keepTimestamps.contains(entry.deliveredAt.toIso8601String()),
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listFromUntilEndOfDay(
    DateTime instant,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));

    final entries =
        _entries
            .where(
              (entry) =>
                  entry.deliveredAt.isAfter(instant) &&
                  entry.deliveredAt.isBefore(end),
            )
            .toList(growable: false)
          ..sort((a, b) => a.deliveredAt.compareTo(b.deliveredAt));

    return entries;
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final entries =
        _entries
            .where(
              (entry) =>
                  !entry.deliveredAt.isBefore(start) &&
                  entry.deliveredAt.isBefore(end),
            )
            .toList(growable: false)
          ..sort((a, b) => b.deliveredAt.compareTo(a.deliveredAt));

    return entries;
  }
}
