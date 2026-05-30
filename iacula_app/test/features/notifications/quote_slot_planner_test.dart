import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/quote_slot_planner.dart';

void main() {
  test('spreads interval slots across the default 08:00-22:00 window', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 180, // 3h
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 22 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, [8 * 60, 11 * 60, 14 * 60, 17 * 60, 20 * 60]);
  });

  test('caps the number of slots at maxSlots', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 22 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots.length, 6);
    expect(slots.first, 8 * 60);
  });

  test('skips slots that fall inside quiet hours', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 6 * 60,
      windowEndMinutes: 23 * 60,
      quietHoursEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    for (final minutes in slots) {
      final inQuiet = minutes >= 22 * 60 || minutes < 7 * 60;
      expect(inQuiet, isFalse, reason: 'slot $minutes inside quiet hours');
    }
  });

  test('returns at least one slot even with a huge interval', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 360,
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 9 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, [8 * 60]);
  });

  test('returns empty when the whole window is quiet', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 23 * 60,
      windowEndMinutes: 23 * 60 + 30,
      quietHoursEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, isEmpty);
  });
}
