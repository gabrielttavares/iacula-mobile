/// Determines the psalter week (1-4) for a given date.
/// The psalter cycle follows a 4-week rotation aligned with the liturgical year.
final class PsalterCalendar {
  const PsalterCalendar();

  /// Returns the psalter week (1-4) for the given date.
  /// Uses a simplified calculation based on the week number of the year.
  int psalterWeek(DateTime date) {
    final weekOfYear = _weekOfYear(date);
    return (weekOfYear % 4) + 1;
  }

  int _weekOfYear(DateTime date) {
    final jan1 = DateTime(date.year, 1, 1);
    final diff = date.difference(jan1).inDays;
    return (diff / 7).floor() + 1;
  }
}
