final class EasterCalculator {
  const EasterCalculator._();

  static DateTime easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  static DateTime pentecostSunday(int year) =>
      easterSunday(year).add(const Duration(days: 49));

  static bool isWithinEasterSeason(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final easter = easterSunday(day.year);
    final pentecost = pentecostSunday(day.year);
    return !day.isBefore(easter) && !day.isAfter(pentecost);
  }
}
