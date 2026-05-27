import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_season_transitions_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';

void main() {
  late InMemoryNotificationSchedulerRepository scheduler;

  setUp(() {
    scheduler = InMemoryNotificationSchedulerRepository();
  });

  test('schedules Easter and Pentecost transitions when both are in the future', () async {
    // 2026: Easter is April 5, Pentecost is May 24 (Easter + 49)
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(transitions, hasLength(2));

    // First: Easter Sunday midnight → switch to Regina Caeli
    expect(transitions[0].scheduledAt, DateTime(2026, 4, 5, 0, 0));
    expect(transitions[0].prayerSlug, 'regina-coeli');
    expect(transitions[0].repeatDaily, isFalse);
    expect(transitions[0].scheduledId, ScheduleSeasonTransitionsUseCase.easterTransitionId);

    // Second: day after Pentecost midnight → switch back to Angelus
    expect(transitions[1].scheduledAt, DateTime(2026, 5, 25, 0, 0));
    expect(transitions[1].prayerSlug, 'angelus');
    expect(transitions[1].repeatDaily, isFalse);
    expect(transitions[1].scheduledId, ScheduleSeasonTransitionsUseCase.pentecostTransitionId);
  });

  test('skips Easter transition when Easter is already past', () async {
    // During Easter season: Easter was April 5, now is April 20
    final now = DateTime(2026, 4, 20, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    expect(transitions, hasLength(1));
    // Only the Pentecost transition should be scheduled
    expect(transitions[0].prayerSlug, 'angelus');
    expect(transitions[0].scheduledAt, DateTime(2026, 5, 25, 0, 0));
  });

  test('skips both transitions when both are already past', () async {
    // After Pentecost: both transitions are in the past
    final now = DateTime(2026, 6, 10, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    expect(transitions, isEmpty);
  });

  test('cancels previous transition notifications before scheduling new ones', () async {
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    // Schedule once
    await useCase.call(now: now);
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.seasonTransition),
      hasLength(2),
    );

    // Schedule again (e.g. from a rebuild) — should still be exactly 2, not 4
    await useCase.call(now: now);
    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();
    expect(transitions, hasLength(2));
  });

  test('transition notifications are not alarms and have no vibration', () async {
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    for (final transition in transitions) {
      expect(transition.isAlarm, isFalse);
      expect(transition.withVibration, isFalse);
    }
  });

  test('handles 2025 Easter date correctly', () async {
    // 2025: Easter is April 20, Pentecost is June 8
    final now = DateTime(2025, 1, 1);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(transitions, hasLength(2));
    expect(transitions[0].scheduledAt, DateTime(2025, 4, 20, 0, 0));
    expect(transitions[1].scheduledAt, DateTime(2025, 6, 9, 0, 0));
  });
}
