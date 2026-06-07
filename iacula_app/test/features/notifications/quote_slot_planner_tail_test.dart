import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/active_window.dart';
import 'package:iacula_app/features/notifications/domain/services/quote_slot_planner.dart';

void main() {
  group('QuoteSlotPlanner.multiDaySlotsWithTail', () {
    const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);

    test('dense days use the full cadence, tail days use the wider cadence', () {
      final now = DateTime(2026, 6, 1, 7, 0); // Monday 07:00
      final slots = QuoteSlotPlanner.multiDaySlotsWithTail(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 100, // effectively uncapped; let the window decide
        denseRunwayDays: 2,
        tailCadenceMinutes: 120,
        tailHorizonDays: 4,
      );

      int countOnDay(int day) => slots.where((s) => s.day == day).length;

      // Days 1-2 (dense, 60-min cadence) hold more slots than days 3-4 (tail,
      // 120-min cadence) over the same 14h window.
      final denseDayCount = countOnDay(1);
      final tailDayCount = countOnDay(3);
      expect(denseDayCount, greaterThan(tailDayCount));
      expect(countOnDay(4), tailDayCount); // tail is steady
    });

    test('tail begins exactly after the dense runway', () {
      final now = DateTime(2026, 6, 1, 7, 0);
      final slots = QuoteSlotPlanner.multiDaySlotsWithTail(
        now: now,
        window: window,
        cadenceMinutes: 30,
        slotsPerDay: 100,
        denseRunwayDays: 3,
        tailCadenceMinutes: 60,
        tailHorizonDays: 6,
      );

      // Every dense day (1,2,3) and every tail day (4,5,6) is represented.
      for (final day in [1, 2, 3, 4, 5, 6]) {
        expect(slots.any((s) => s.day == day), isTrue,
            reason: 'expected at least one slot on day $day');
      }
      // No slots past the tail horizon.
      expect(slots.any((s) => s.day > 6), isFalse);
    });

    test('no tail when horizon equals the dense runway', () {
      final now = DateTime(2026, 6, 1, 7, 0);
      final withTail = QuoteSlotPlanner.multiDaySlotsWithTail(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 100,
        denseRunwayDays: 3,
        tailCadenceMinutes: 120,
        tailHorizonDays: 3,
      );
      final denseOnly = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 100,
        days: 3,
      );
      expect(withTail, denseOnly);
    });

    test('slots are strictly increasing, in-window, and skip noon', () {
      final now = DateTime(2026, 6, 1, 7, 0);
      final slots = QuoteSlotPlanner.multiDaySlotsWithTail(
        now: now,
        window: window,
        cadenceMinutes: 30,
        slotsPerDay: 100,
        denseRunwayDays: 3,
        tailCadenceMinutes: 60,
        tailHorizonDays: 7,
      );
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i].isAfter(slots[i - 1]), isTrue);
      }
      for (final slot in slots) {
        expect(window.allows(slot), isTrue);
        expect(slot.hour, isNot(12));
      }
    });
  });
}
