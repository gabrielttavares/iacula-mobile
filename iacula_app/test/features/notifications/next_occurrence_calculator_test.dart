import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/next_occurrence_calculator.dart';

void main() {
  test('returns same day when target is later today', () {
    final now = DateTime(2026, 2, 21, 8, 0);
    final next = NextOccurrenceCalculator.forHourMinute(now: now, hhmm: '12:30');

    expect(next, DateTime(2026, 2, 21, 12, 30));
  });

  test('returns next day when target already passed', () {
    final now = DateTime(2026, 2, 21, 21, 0);
    final next = NextOccurrenceCalculator.forHourMinute(now: now, hhmm: '06:00');

    expect(next, DateTime(2026, 2, 22, 6, 0));
  });
}
