import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/quiet_hours_checker.dart';

void main() {
  group('QuietHoursChecker.isDuringQuietHours', () {
    test('same-day window is inclusive at start and exclusive at end', () {
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 13, 0),
          '13:00',
          '15:00',
        ),
        isTrue,
      );
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 14, 59),
          '13:00',
          '15:00',
        ),
        isTrue,
      );
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 15, 0),
          '13:00',
          '15:00',
        ),
        isFalse,
      );
    });

    test('overnight window includes late night and early morning', () {
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 23, 0),
          '22:00',
          '07:00',
        ),
        isTrue,
      );
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 2, 3, 0),
          '22:00',
          '07:00',
        ),
        isTrue,
      );
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 10, 0),
          '22:00',
          '07:00',
        ),
        isFalse,
      );
    });

    test('equal start and end means no quiet hours', () {
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 1, 0),
          '22:00',
          '22:00',
        ),
        isFalse,
      );
      expect(
        QuietHoursChecker.isDuringQuietHours(
          DateTime(2026, 3, 1, 22, 0),
          '22:00',
          '22:00',
        ),
        isFalse,
      );
    });
  });

  group('QuietHoursChecker.nextActiveTime', () {
    test('returns same-day end when end is after candidate', () {
      final result = QuietHoursChecker.nextActiveTime(
        DateTime(2026, 3, 1, 13, 10),
        '15:00',
      );

      expect(result, DateTime(2026, 3, 1, 15, 0));
    });

    test('returns next-day end when end is not after candidate', () {
      final result = QuietHoursChecker.nextActiveTime(
        DateTime(2026, 3, 1, 23, 10),
        '07:00',
      );

      expect(result, DateTime(2026, 3, 2, 7, 0));
    });
  });
}
