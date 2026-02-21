import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/services/prayer_scheduler.dart';

void main() {
  test('calculates next noon same day when morning', () {
    final now = DateTime(2026, 2, 21, 10, 0);
    final result = PrayerScheduler.calculateNextNoon(now);

    expect(result.nextTriggerTime, DateTime(2026, 2, 21, 12));
    expect(result.delay, const Duration(hours: 2));
  });

  test('calculates next noon next day when after noon', () {
    final now = DateTime(2026, 2, 21, 13, 0);
    final result = PrayerScheduler.calculateNextNoon(now);

    expect(result.nextTriggerTime, DateTime(2026, 2, 22, 12));
  });
}
