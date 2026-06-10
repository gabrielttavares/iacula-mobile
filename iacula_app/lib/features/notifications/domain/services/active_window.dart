/// The daily span during which notifications may fire, expressed as
/// minutes-of-day. Outside this window the app sends nothing — there is no
/// separate "quiet hours" concept, the window IS the single source of truth.
///
/// Supports overnight wrap-around (e.g. 22:00–06:00) where [startMinutes] is
/// greater than [endMinutes]. The end is exclusive.
final class ActiveWindow {
  const ActiveWindow({required this.startMinutes, required this.endMinutes});

  /// Window bounds as minutes-of-day (0–1439).
  final int startMinutes;
  final int endMinutes;

  /// The proven default span (07:00–21:00) used before a user customizes it.
  static const ActiveWindow defaultWindow = ActiveWindow(
    startMinutes: 7 * 60,
    endMinutes: 21 * 60,
  );

  /// Builds a window from `HH:MM` strings (e.g. the persisted settings fields).
  factory ActiveWindow.fromHHMM({required String start, required String end}) {
    return ActiveWindow(
      startMinutes: _parseMinutes(start),
      endMinutes: _parseMinutes(end),
    );
  }

  /// The window from `HH:MM` bounds, falling back to [defaultWindow] when the
  /// bounds are invalid (start == end). This is the single resolution point used
  /// by every scheduler, so the valid/default rule never drifts between them.
  factory ActiveWindow.resolve({required String start, required String end}) {
    final window = ActiveWindow.fromHHMM(start: start, end: end);
    return window.isValid ? window : defaultWindow;
  }

  /// The allowed window derived from a user-set QUIET-HOURS range
  /// [quietStart, quietEnd): notifications fire everywhere EXCEPT the quiet
  /// range, so the allowed window is its complement (quietEnd .. quietStart).
  /// A quiet range of 22:00-07:00 yields an allowed window of 07:00-22:00.
  /// Falls back to the default quiet hours (silent 22:00-07:00 -> active
  /// 07:00-22:00) when the bounds are invalid.
  factory ActiveWindow.fromQuietHours({
    required String quietStart,
    required String quietEnd,
  }) {
    final quiet = ActiveWindow.fromHHMM(start: quietStart, end: quietEnd);
    if (!quiet.isValid) {
      return const ActiveWindow(startMinutes: 7 * 60, endMinutes: 22 * 60);
    }
    // Allowed = complement of quiet: swap the bounds.
    return ActiveWindow(
      startMinutes: quiet.endMinutes,
      endMinutes: quiet.startMinutes,
    );
  }

  /// A window is only meaningful when start and end differ. Equal bounds would
  /// mean either "never" or "always" — we treat it as invalid so the UI can
  /// reject it and callers can fall back to the default.
  bool get isValid => startMinutes != endMinutes;

  /// Whether [time]'s clock position falls within the window (end exclusive).
  bool allows(DateTime time) {
    final minutesOfDay = time.hour * 60 + time.minute;
    if (startMinutes < endMinutes) {
      return minutesOfDay >= startMinutes && minutesOfDay < endMinutes;
    }
    // Overnight wrap-around: inside if at/after start OR before end.
    return minutesOfDay >= startMinutes || minutesOfDay < endMinutes;
  }

  /// The earliest instant at or after [from] that the window admits. Returns
  /// [from] unchanged when it is already inside the window; otherwise advances
  /// to the next window start (today or tomorrow).
  DateTime nextAllowedAtOrAfter(DateTime from) {
    if (allows(from)) return from;

    final startHour = startMinutes ~/ 60;
    final startMinute = startMinutes % 60;
    var candidate = DateTime(
      from.year,
      from.month,
      from.day,
      startHour,
      startMinute,
    );
    if (!candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Number of cadence-aligned slots that fit in the window for one day, given
  /// a step of [cadenceMinutes]. Used to size the per-day quote density.
  int slotCount({required int cadenceMinutes}) {
    if (cadenceMinutes <= 0) return 0;
    final spanMinutes = startMinutes < endMinutes
        ? endMinutes - startMinutes
        : (24 * 60 - startMinutes) + endMinutes; // overnight wrap-around
    // Cadence-aligned offsets 0, cadence, 2*cadence ... up to and including
    // spanMinutes.
    return (spanMinutes ~/ cadenceMinutes) + 1;
  }

  static int _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }
}
