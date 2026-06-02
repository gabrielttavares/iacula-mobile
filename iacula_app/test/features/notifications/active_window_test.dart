import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/active_window.dart';

void main() {
  group('ActiveWindow.allows', () {
    test('daytime window 07:00-21:00 admits inside, rejects outside', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      expect(window.allows(DateTime(2026, 6, 2, 7, 0)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 12, 30)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 20, 59)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 21, 0)), isFalse); // end exclusive
      expect(window.allows(DateTime(2026, 6, 2, 6, 59)), isFalse);
      expect(window.allows(DateTime(2026, 6, 2, 3, 0)), isFalse);
    });

    test('overnight window 22:00-06:00 admits across midnight', () {
      const window = ActiveWindow(startMinutes: 22 * 60, endMinutes: 6 * 60);
      expect(window.allows(DateTime(2026, 6, 2, 22, 0)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 23, 30)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 0, 0)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 5, 59)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 6, 0)), isFalse); // end exclusive
      expect(window.allows(DateTime(2026, 6, 2, 12, 0)), isFalse);
    });

    test('narrow window 06:30-08:30', () {
      const window = ActiveWindow(startMinutes: 6 * 60 + 30, endMinutes: 8 * 60 + 30);
      expect(window.allows(DateTime(2026, 6, 2, 6, 30)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 8, 0)), isTrue);
      expect(window.allows(DateTime(2026, 6, 2, 8, 30)), isFalse);
      expect(window.allows(DateTime(2026, 6, 2, 9, 0)), isFalse);
      expect(window.allows(DateTime(2026, 6, 2, 6, 0)), isFalse);
    });
  });

  group('ActiveWindow.nextAllowedAtOrAfter', () {
    test('returns same time when already inside the window', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      final now = DateTime(2026, 6, 2, 9, 15);
      expect(window.nextAllowedAtOrAfter(now), now);
    });

    test('before window start jumps to start same day', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      final now = DateTime(2026, 6, 2, 5, 0);
      expect(window.nextAllowedAtOrAfter(now), DateTime(2026, 6, 2, 7, 0));
    });

    test('after window end jumps to start of next day', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      final now = DateTime(2026, 6, 2, 22, 0);
      expect(window.nextAllowedAtOrAfter(now), DateTime(2026, 6, 3, 7, 0));
    });

    test('overnight window: a midday time jumps to that evening start', () {
      const window = ActiveWindow(startMinutes: 22 * 60, endMinutes: 6 * 60);
      final now = DateTime(2026, 6, 2, 12, 0);
      expect(window.nextAllowedAtOrAfter(now), DateTime(2026, 6, 2, 22, 0));
    });

    test('overnight window: an after-midnight inside time stays put', () {
      const window = ActiveWindow(startMinutes: 22 * 60, endMinutes: 6 * 60);
      final now = DateTime(2026, 6, 2, 2, 0);
      expect(window.nextAllowedAtOrAfter(now), now);
    });
  });

  group('ActiveWindow.fromHHMM', () {
    test('parses HH:MM strings', () {
      final window = ActiveWindow.fromHHMM(start: '07:00', end: '21:00');
      expect(window.startMinutes, 7 * 60);
      expect(window.endMinutes, 21 * 60);
    });

    test('isValid is false when start equals end', () {
      final window = ActiveWindow.fromHHMM(start: '09:00', end: '09:00');
      expect(window.isValid, isFalse);
    });

    test('isValid is true for distinct start and end', () {
      final window = ActiveWindow.fromHHMM(start: '07:00', end: '21:00');
      expect(window.isValid, isTrue);
    });

    test('exposes the default 07:00-21:00 window', () {
      expect(ActiveWindow.defaultWindow.startMinutes, 7 * 60);
      expect(ActiveWindow.defaultWindow.endMinutes, 21 * 60);
    });

    test('resolve falls back to the default when bounds are invalid', () {
      final invalid = ActiveWindow.resolve(start: '09:00', end: '09:00');
      expect(invalid.startMinutes, ActiveWindow.defaultWindow.startMinutes);
      final valid = ActiveWindow.resolve(start: '06:30', end: '08:30');
      expect(valid.startMinutes, 6 * 60 + 30);
    });
  });

  group('ActiveWindow.slotCount', () {
    test('hourly across 07:00-21:00 skips the noon hour', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      // 07..21 inclusive = 15 steps, minus the 12:00 noon slot = 14.
      expect(window.slotCount(cadenceMinutes: 60), 14);
    });

    test('two-hour cadence', () {
      const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);
      // 07,09,11,13,15,17,19,21 = 8 (none land in the noon hour).
      expect(window.slotCount(cadenceMinutes: 120), 8);
    });

    test('overnight window counts across midnight', () {
      const window = ActiveWindow(startMinutes: 22 * 60, endMinutes: 6 * 60);
      // 22,23,00,01,02,03,04,05,06 = 9 (noon hour never reached).
      expect(window.slotCount(cadenceMinutes: 60), 9);
    });
  });
}
