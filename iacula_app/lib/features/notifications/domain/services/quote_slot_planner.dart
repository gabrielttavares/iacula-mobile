import 'active_window.dart';

/// Computes concrete fire times for the pre-rolled multi-day quote queue.
/// Pure and deterministic.
final class QuoteSlotPlanner {
  const QuoteSlotPlanner._();

  /// Concrete fire times for the pre-rolled multi-day quote queue.
  ///
  /// Produces up to [slotsPerDay] slots for each of the next [days] calendar
  /// days (today first), spaced by [cadenceMinutes] and confined to [window].
  /// Today's slots start at the first cadence-aligned time at or after `now`;
  /// future days start at the window's opening. The noon hour (reserved for
  /// Angelus) is always skipped. Slots never land in the past and are returned
  /// strictly increasing.
  ///
  /// Slots align to the window-start grid so they sit on stable clock times
  /// regardless of when the pass runs, which lets a later rebuild reuse an
  /// already-assigned slot by its timestamp.
  static List<DateTime> multiDaySlots({
    required DateTime now,
    required ActiveWindow window,
    required int cadenceMinutes,
    required int slotsPerDay,
    required int days,
  }) {
    if (cadenceMinutes <= 0 || slotsPerDay <= 0 || days <= 0) {
      return const <DateTime>[];
    }

    final startHour = window.startMinutes ~/ 60;
    final startMinute = window.startMinutes % 60;
    final perDayCount = <DateTime, int>{};
    final slots = <DateTime>[];

    // Walk a continuous cadence timeline from the window opening on `now`'s day.
    // A continuous walk (rather than resetting per day) handles overnight
    // windows that cross midnight cleanly: the grid simply keeps stepping and
    // the window membership test decides what is admitted.
    var cursor = DateTime(now.year, now.month, now.day, startHour, startMinute);

    // The horizon is `days` calendar days from today. An overnight window's
    // last night spills past midnight into the following morning, so extend the
    // walk one extra day to reach those after-midnight slots (they are still
    // bucketed to the last logical day via _windowBucketDay).
    final overnight = window.startMinutes > window.endMinutes;
    final horizon = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: overnight ? days + 1 : days));

    while (cursor.isBefore(horizon)) {
      final inPast = cursor.isBefore(now);
      final inNoonHour = cursor.hour == 12;
      if (!inPast && !inNoonHour && window.allows(cursor)) {
        // Attribute the slot to the calendar day the window OPENED on, so an
        // overnight window's after-midnight slots still count toward the same
        // logical day's budget rather than starting a new day's allocation.
        final bucketDay = _windowBucketDay(cursor, window);
        final used = perDayCount[bucketDay] ?? 0;
        if (used < slotsPerDay) {
          slots.add(cursor);
          perDayCount[bucketDay] = used + 1;
        }
      }
      cursor = cursor.add(Duration(minutes: cadenceMinutes));
    }

    return slots;
  }

  /// The calendar day a slot's logical "active window day" opened on. For a
  /// same-day window this is just the slot's date; for an overnight window an
  /// after-midnight slot belongs to the previous calendar day's window.
  static DateTime _windowBucketDay(DateTime slot, ActiveWindow window) {
    final overnight = window.startMinutes > window.endMinutes;
    final minutesOfDay = slot.hour * 60 + slot.minute;
    if (overnight && minutesOfDay < window.endMinutes) {
      final previous = slot.subtract(const Duration(days: 1));
      return DateTime(previous.year, previous.month, previous.day);
    }
    return DateTime(slot.year, slot.month, slot.day);
  }
}
