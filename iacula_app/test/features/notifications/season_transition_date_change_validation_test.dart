import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/easter_calculator.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_season_transitions_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';

void main() {
  group('Season transition date boundary validation', () {
    late InMemoryNotificationSchedulerRepository scheduler;
    late ScheduleSeasonTransitionsUseCase useCase;

    setUp(() {
      scheduler = InMemoryNotificationSchedulerRepository();
      useCase = ScheduleSeasonTransitionsUseCase(scheduler);
    });

    // 2027: Easter = March 28, Pentecost = May 16
    test('day before Easter: both transitions scheduled', () async {
      await useCase.call(now: DateTime(2027, 3, 27, 23, 59));

      final transitions = scheduler.events
          .where((e) => e.type == ReminderEventType.seasonTransition)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      expect(transitions, hasLength(2));
      expect(transitions[0].scheduledAt, DateTime(2027, 3, 28));
      expect(transitions[0].prayerSlug, 'regina-coeli');
      expect(transitions[1].scheduledAt, DateTime(2027, 5, 17));
      expect(transitions[1].prayerSlug, 'angelus');
    });

    test('Easter Sunday: only Pentecost transition scheduled', () async {
      await useCase.call(now: DateTime(2027, 3, 28, 0, 1));

      final transitions = scheduler.events
          .where((e) => e.type == ReminderEventType.seasonTransition)
          .toList();

      expect(transitions, hasLength(1));
      expect(transitions[0].prayerSlug, 'angelus');
      expect(transitions[0].scheduledAt, DateTime(2027, 5, 17));
    });

    test('mid-Easter season: only Pentecost transition', () async {
      await useCase.call(now: DateTime(2027, 4, 15, 12, 0));

      final transitions = scheduler.events
          .where((e) => e.type == ReminderEventType.seasonTransition)
          .toList();

      expect(transitions, hasLength(1));
      expect(transitions[0].prayerSlug, 'angelus');
    });

    test('Pentecost Sunday: back-to-Angelus transition still pending', () async {
      await useCase.call(now: DateTime(2027, 5, 16, 12, 0));

      final transitions = scheduler.events
          .where((e) => e.type == ReminderEventType.seasonTransition)
          .toList();

      expect(transitions, hasLength(1));
      expect(transitions[0].prayerSlug, 'angelus');
      expect(transitions[0].scheduledAt, DateTime(2027, 5, 17));
    });

    test('day after Pentecost: no transitions left', () async {
      await useCase.call(now: DateTime(2027, 5, 17, 0, 1));

      final transitions = scheduler.events
          .where((e) => e.type == ReminderEventType.seasonTransition)
          .toList();

      expect(transitions, isEmpty);
    });

    test('EasterCalculator matches known dates for 2025-2030', () {
      final knownEasterDates = {
        2025: DateTime(2025, 4, 20),
        2026: DateTime(2026, 4, 5),
        2027: DateTime(2027, 3, 28),
        2028: DateTime(2028, 4, 16),
        2029: DateTime(2029, 4, 1),
        2030: DateTime(2030, 4, 21),
      };

      for (final entry in knownEasterDates.entries) {
        expect(
          EasterCalculator.easterSunday(entry.key),
          entry.value,
          reason: 'Easter ${entry.key} should be ${entry.value}',
        );
      }
    });

    test('isWithinEasterSeason boundaries are inclusive', () {
      // 2027: Easter = March 28, Pentecost = May 16
      expect(EasterCalculator.isWithinEasterSeason(DateTime(2027, 3, 27)), isFalse);
      expect(EasterCalculator.isWithinEasterSeason(DateTime(2027, 3, 28)), isTrue);
      expect(EasterCalculator.isWithinEasterSeason(DateTime(2027, 5, 16)), isTrue);
      expect(EasterCalculator.isWithinEasterSeason(DateTime(2027, 5, 17)), isFalse);
    });
  });
}
