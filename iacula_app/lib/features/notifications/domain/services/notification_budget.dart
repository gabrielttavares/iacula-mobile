/// Tracks how many of the iOS 64-pending notification slots remain while a
/// rebuild schedules across features. It is the single enforcement point that
/// keeps the app from silently blowing past the OS cap: higher-priority tiers
/// (Angelus, season transitions, liturgy, prayer intentions) consume first, and
/// lower-priority quotes fill whatever is left. Each would-be notification must
/// pass [tryConsume] before being scheduled.
final class NotificationBudget {
  NotificationBudget({required this.capacity}) : _consumed = 0;

  /// The hard ceiling (64 on iOS).
  final int capacity;

  int _consumed;

  int get consumed => _consumed;

  int get remaining => capacity - _consumed;

  bool get isExhausted => remaining <= 0;

  /// Grants one slot if any remain. Returns whether the caller may schedule.
  bool tryConsume() {
    if (isExhausted) return false;
    _consumed++;
    return true;
  }

  /// Sets aside [count] slots up front for a higher-priority tier whose exact
  /// scheduling happens elsewhere. Over-reservation clamps to the remaining
  /// capacity rather than going negative.
  void reserve(int count) {
    if (count <= 0) return;
    _consumed += count > remaining ? remaining : count;
  }
}
