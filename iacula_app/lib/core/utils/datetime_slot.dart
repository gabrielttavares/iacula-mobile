/// Slot-time helpers for notification scheduling.
extension DateTimeSlot on DateTime {
  /// This instant truncated to the whole minute (seconds and milliseconds
  /// dropped). Scheduled slots are floored so a later rebuild can match and
  /// REUSE an already-assigned slot by its ISO timestamp instead of re-rolling
  /// it — keeping the OS-scheduled quote stable across app reopens.
  DateTime flooredToMinute() => DateTime(year, month, day, hour, minute);
}
