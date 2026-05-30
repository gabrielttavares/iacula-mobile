import 'quiet_hours_checker.dart';

/// Default daily active window used when quiet hours are disabled.
const int kQuoteWindowStartMinutes = 7 * 60; // 07:00
const int kQuoteWindowEndMinutes = 22 * 60; // 22:00

/// Maximum quote notification slots per weekday. With a 7-weekday grid this
/// caps quote notifications at 7 * 6 = 42, leaving headroom under the iOS
/// 64-pending-notification limit for Angelus, alarms, and intentions.
const int kMaxQuoteSlotsPerWeekday = 6;

/// Computes the clock times (as minutes-of-day) at which quote notifications
/// should fire on any given weekday. Pure and deterministic for a given input.
final class QuoteSlotPlanner {
  const QuoteSlotPlanner._();

  static List<int> slotMinutesOfDay({
    required int intervalMinutes,
    required int windowStartMinutes,
    required int windowEndMinutes,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
    required int maxSlots,
  }) {
    if (intervalMinutes <= 0 || windowEndMinutes <= windowStartMinutes) {
      return const <int>[];
    }

    // Reference date is arbitrary: the quiet-hours check only reads the
    // hour/minute of the supplied time, so any date works for a slot's
    // clock-time lookup.
    final referenceDate = DateTime(2026);

    final slots = <int>[];
    var cursor = windowStartMinutes;
    while (cursor <= windowEndMinutes && slots.length < maxSlots) {
      final isQuiet = quietHoursEnabled &&
          QuietHoursChecker.isDuringQuietHours(
            referenceDate.add(Duration(minutes: cursor)),
            quietHoursStart,
            quietHoursEnd,
          );
      if (!isQuiet) {
        slots.add(cursor);
      }
      cursor += intervalMinutes;
    }
    return slots;
  }
}
