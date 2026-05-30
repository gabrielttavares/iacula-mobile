import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/quote_slot_planner.dart';

void main() {
  group('noon-hour skip', () {
    test('slotMinutesOfDay never lands in the noon hour (12:00-12:59)', () {
      final slots = QuoteSlotPlanner.slotMinutesOfDay(
        intervalMinutes: 60,
        windowStartMinutes: 7 * 60,
        windowEndMinutes: 21 * 60,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
        maxSlots: 20,
      );
      for (final minutes in slots) {
        final inNoon = minutes >= 12 * 60 && minutes < 13 * 60;
        expect(inNoon, isFalse, reason: 'slot $minutes is in the noon hour');
      }
      // Hourly 07-21 skipping the noon hour -> 07,08,09,10,11,13,...,21 = 14.
      expect(slots.length, 14);
    });
  });

  group('todaySlotsFrom', () {
    test('walks from the next aligned slot at/after now to window end', () {
      final now = DateTime(2026, 5, 31, 8, 0); // 08:00
      final slots = QuoteSlotPlanner.todaySlotsFrom(
        now: now,
        cadenceMinutes: 60,
        windowStartMinutes: 7 * 60,
        windowEndMinutes: 21 * 60,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      );
      // First slot at/after 08:00 aligned to the 07:00 grid is 08:00.
      expect(slots.first, DateTime(2026, 5, 31, 8, 0));
      // Last slot <= 21:00.
      expect(slots.last, DateTime(2026, 5, 31, 21, 0));
      // No slot in the noon hour.
      for (final slot in slots) {
        expect(slot.hour, isNot(12));
      }
      // All slots are today and strictly increasing.
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i].isAfter(slots[i - 1]), isTrue);
        expect(slots[i].day, 31);
      }
    });

    test('aligns slots to the window grid even when now is off-grid', () {
      final now = DateTime(2026, 5, 31, 8, 20); // 08:20, off the hourly grid
      final slots = QuoteSlotPlanner.todaySlotsFrom(
        now: now,
        cadenceMinutes: 60,
        windowStartMinutes: 7 * 60,
        windowEndMinutes: 21 * 60,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      );
      // Next aligned hourly slot at/after 08:20 is 09:00.
      expect(slots.first, DateTime(2026, 5, 31, 9, 0));
    });

    test('returns empty when now is past the window end', () {
      final now = DateTime(2026, 5, 31, 21, 30);
      final slots = QuoteSlotPlanner.todaySlotsFrom(
        now: now,
        cadenceMinutes: 60,
        windowStartMinutes: 7 * 60,
        windowEndMinutes: 21 * 60,
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      );
      expect(slots, isEmpty);
    });

    test('skips slots inside quiet hours', () {
      final now = DateTime(2026, 5, 31, 7, 0);
      final slots = QuoteSlotPlanner.todaySlotsFrom(
        now: now,
        cadenceMinutes: 60,
        windowStartMinutes: 7 * 60,
        windowEndMinutes: 21 * 60,
        quietHoursEnabled: true,
        quietHoursStart: '20:00',
        quietHoursEnd: '07:00',
      );
      // 20:00 and 21:00 fall in quiet hours (>= 20:00) -> excluded.
      for (final slot in slots) {
        expect(slot.hour < 20, isTrue, reason: '${slot.hour} in quiet hours');
      }
    });
  });
}
