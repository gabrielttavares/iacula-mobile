final class QuietHoursChecker {
  const QuietHoursChecker._();

  static bool isDuringQuietHours(
    DateTime time,
    String startHHMM,
    String endHHMM,
  ) {
    final startMinutes = _parseMinutes(startHHMM);
    final endMinutes = _parseMinutes(endHHMM);
    if (startMinutes == endMinutes) {
      return false;
    }

    final currentMinutes = time.hour * 60 + time.minute;
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  static DateTime nextActiveTime(DateTime candidate, String endHHMM) {
    final endMinutes = _parseMinutes(endHHMM);
    final endHour = endMinutes ~/ 60;
    final endMinute = endMinutes % 60;
    var endAt = DateTime(
      candidate.year,
      candidate.month,
      candidate.day,
      endHour,
      endMinute,
    );
    if (!endAt.isAfter(candidate)) {
      endAt = endAt.add(const Duration(days: 1));
    }
    return endAt;
  }

  static int _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return hour * 60 + minute;
  }
}
