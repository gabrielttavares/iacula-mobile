import 'quiet_hours_checker.dart';

/// Default daily active window for quote notifications.
const int kQuoteWindowStartMinutes = 7 * 60; // 07:00
const int kQuoteWindowEndMinutes = 21 * 60; // 21:00

/// Weekly grid floor density (cells per weekday). The 7-weekday grid is the
/// "fires while closed" layer; capping at 5 keeps it at 7 * 5 = 35 cells, well
/// under the iOS 64-pending limit once the dense today layer and Angelus share
/// the budget.
const int kMaxQuoteSlotsPerWeekday = 5;

/// The noon hour (12:00-12:59) is reserved for the Angelus / Regina Caeli alarm.
/// Quote slots never schedule here, on any layer.
const int _noonHourStartMinutes = 12 * 60;
const int _noonHourEndMinutes = 13 * 60;

/// Computes quote notification clock times. Pure and deterministic.
///
/// Used by both notification layers:
/// - [slotMinutesOfDay] returns minutes-of-day for the weekly grid floor.
/// - [todaySlotsFrom] returns concrete [DateTime]s for the dense "today" layer.
final class QuoteSlotPlanner {
  const QuoteSlotPlanner._();

  /// Weekly-grid slot clock-times (minutes-of-day) for any weekday.
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

    final slots = <int>[];
    var cursor = windowStartMinutes;
    while (cursor <= windowEndMinutes && slots.length < maxSlots) {
      if (!_isExcluded(
        minutesOfDay: cursor,
        quietHoursEnabled: quietHoursEnabled,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      )) {
        slots.add(cursor);
      }
      cursor += intervalMinutes;
    }
    return slots;
  }

  /// Concrete fire times for today's dense one-shot layer.
  ///
  /// Walks from the first cadence-aligned slot at or after [now] through the
  /// window end, on the same calendar day as [now], skipping the noon hour and
  /// quiet hours. Slots align to the window-start grid (e.g. 07:00 + k*cadence)
  /// so they land on stable clock times regardless of when the pass runs.
  static List<DateTime> todaySlotsFrom({
    required DateTime now,
    required int cadenceMinutes,
    required int windowStartMinutes,
    required int windowEndMinutes,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) {
    if (cadenceMinutes <= 0 || windowEndMinutes <= windowStartMinutes) {
      return const <DateTime>[];
    }

    final nowMinutes = now.hour * 60 + now.minute;

    // First aligned slot at or after max(now, windowStart).
    final lowerBound =
        nowMinutes > windowStartMinutes ? nowMinutes : windowStartMinutes;
    var cursor = windowStartMinutes;
    while (cursor < lowerBound) {
      cursor += cadenceMinutes;
    }

    final slots = <DateTime>[];
    while (cursor <= windowEndMinutes) {
      if (!_isExcluded(
        minutesOfDay: cursor,
        quietHoursEnabled: quietHoursEnabled,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      )) {
        slots.add(DateTime(
          now.year,
          now.month,
          now.day,
          cursor ~/ 60,
          cursor % 60,
        ));
      }
      cursor += cadenceMinutes;
    }
    return slots;
  }

  static bool _isExcluded({
    required int minutesOfDay,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) {
    // Noon hour is always reserved for Angelus.
    if (minutesOfDay >= _noonHourStartMinutes &&
        minutesOfDay < _noonHourEndMinutes) {
      return true;
    }
    if (!quietHoursEnabled) return false;
    // Reference date is arbitrary: the quiet-hours check only reads hour/minute.
    final referenceDate = DateTime(2026);
    return QuietHoursChecker.isDuringQuietHours(
      referenceDate.add(Duration(minutes: minutesOfDay)),
      quietHoursStart,
      quietHoursEnd,
    );
  }
}
