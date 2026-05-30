/// Default daily active window used when quiet hours are disabled.
const int kQuoteWindowStartMinutes = 8 * 60; // 08:00
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

    final quietStart = _parseMinutes(quietHoursStart);
    final quietEnd = _parseMinutes(quietHoursEnd);

    final slots = <int>[];
    var cursor = windowStartMinutes;
    while (cursor <= windowEndMinutes && slots.length < maxSlots) {
      final isQuiet = quietHoursEnabled &&
          quietStart != null &&
          quietEnd != null &&
          _isWithinQuiet(cursor, quietStart, quietEnd);
      if (!isQuiet) {
        slots.add(cursor);
      }
      cursor += intervalMinutes;
    }
    return slots;
  }

  /// Quiet window may wrap past midnight (e.g. 22:00 -> 07:00).
  static bool _isWithinQuiet(int minutes, int start, int end) {
    if (start == end) return false;
    if (start < end) {
      return minutes >= start && minutes < end;
    }
    return minutes >= start || minutes < end;
  }

  static int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
}
