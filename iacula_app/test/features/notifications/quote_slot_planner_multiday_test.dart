import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/active_window.dart';
import 'package:iacula_app/features/notifications/domain/services/quote_slot_planner.dart';

void main() {
  group('QuoteSlotPlanner.multiDaySlots', () {
    const window = ActiveWindow(startMinutes: 7 * 60, endMinutes: 21 * 60);

    test('today starts at/after now; future days start at window start', () {
      final now = DateTime(2026, 6, 2, 9, 20); // Tuesday 09:20
      final slots = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: window,
        cadenceMinutes: 120,
        slotsPerDay: 3,
        days: 2,
      );
      final day1 = slots.where((s) => s.day == 2).toList();
      final day2 = slots.where((s) => s.day == 3).toList();

      // Day 1: first aligned slot at/after 09:20 on the 07:00 grid = 11:00.
      expect(day1.first, DateTime(2026, 6, 2, 11, 0));
      // Day 2: starts at window start 07:00.
      expect(day2.first, DateTime(2026, 6, 3, 7, 0));
      // Cap honored per day.
      expect(day1.length, lessThanOrEqualTo(3));
      expect(day2.length, 3);
    });

    test('never schedules in the past and is strictly increasing', () {
      final now = DateTime(2026, 6, 2, 13, 5);
      final slots = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 5,
        days: 3,
      );
      for (final slot in slots) {
        expect(slot.isBefore(now), isFalse);
      }
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i].isAfter(slots[i - 1]), isTrue);
      }
    });

    test('all slots fall inside the active window', () {
      final now = DateTime(2026, 6, 2, 7, 0);
      final slots = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 20, // more than the window holds; planner caps to window
        days: 1,
      );
      for (final slot in slots) {
        expect(window.allows(slot), isTrue, reason: '$slot outside window');
      }
    });

    test('overnight window produces slots spanning midnight', () {
      const overnight = ActiveWindow(startMinutes: 22 * 60, endMinutes: 6 * 60);
      final now = DateTime(2026, 6, 2, 21, 0);
      final slots = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: overnight,
        cadenceMinutes: 60,
        slotsPerDay: 4,
        days: 1,
      );
      // First slot is 22:00 today; slots continue past midnight into day 3.
      expect(slots.first, DateTime(2026, 6, 2, 22, 0));
      expect(slots.any((s) => s.day == 3 && s.hour < 6), isTrue);
    });

    test('returns empty when slotsPerDay is zero', () {
      final now = DateTime(2026, 6, 2, 7, 0);
      final slots = QuoteSlotPlanner.multiDaySlots(
        now: now,
        window: window,
        cadenceMinutes: 60,
        slotsPerDay: 0,
        days: 7,
      );
      expect(slots, isEmpty);
    });
  });
}
