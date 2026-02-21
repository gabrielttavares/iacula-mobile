final class NextOccurrenceCalculator {
  const NextOccurrenceCalculator._();

  static DateTime forHourMinute({
    required DateTime now,
    required String hhmm,
  }) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      throw FormatException('Expected HH:MM, got $hhmm');
    }

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }
}
