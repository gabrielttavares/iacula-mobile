import '../entities/notification_history_entry.dart';

abstract interface class NotificationHistoryRepository {
  Future<void> add(NotificationHistoryEntry entry);
  Future<void> clearFrom(DateTime instant);
  Future<void> clearFromExcept(DateTime instant, Set<String> keepTimestamps);
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day);
  Future<List<NotificationHistoryEntry>> listFromUntilEndOfDay(DateTime instant);

  /// Rows whose `deliveredAt` falls in [from, until] (lower bound inclusive,
  /// upper bound inclusive). Spans multiple days, unlike [listFromUntilEndOfDay].
  /// Used to reuse already-assigned future quote slots across the pre-rolled
  /// multi-day queue so a rebuild keeps a slot's quote instead of re-rolling it.
  Future<List<NotificationHistoryEntry>> listBetween(
    DateTime from,
    DateTime until,
  );

  /// Deletes future rows in (from, until] (lower bound strict so the just-fired
  /// row at `from` is never deleted) except those whose ISO timestamp is in
  /// [keepTimestamps]. Prunes stale slots across the multi-day queue when the
  /// window or cadence changes.
  Future<void> clearBetweenExcept(
    DateTime from,
    DateTime until,
    Set<String> keepTimestamps,
  );
}
