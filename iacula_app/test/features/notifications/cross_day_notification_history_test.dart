import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  group('cross-day notification scheduling', () {
    late InMemoryNotificationSchedulerRepository scheduler;
    late InMemoryNotificationHistoryRepository history;
    late ScheduleCoreRemindersUseCase useCase;

    setUp(() {
      scheduler = InMemoryNotificationSchedulerRepository();
      history = InMemoryNotificationHistoryRepository();
      useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher: ({required String language, required DateTime now}) async {
          return Quote(
            text: 'Quote ${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
            dayOfWeek: now.weekday,
            theme: 'Tema',
            season: LiturgicalSeason.ordinary,
          );
        },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );
    });

    test('scheduling at 23:00 queues notifications that span into next day', () async {
      final now = DateTime(2026, 3, 10, 23, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: now,
        showImmediate: true,
      );

      final quoteEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final todayEvents = quoteEvents.where((e) => e.scheduledAt.day == 10).toList();
      final tomorrowEvents = quoteEvents.where((e) => e.scheduledAt.day == 11).toList();

      expect(todayEvents, isNotEmpty, reason: 'should have events for today');
      expect(tomorrowEvents, isNotEmpty, reason: 'should have events for tomorrow');
    });

    test('immediate delivery and today-layer assignments are recorded',
        () async {
      final now = DateTime(2026, 3, 10, 20, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: now,
        showImmediate: true,
      );

      // The queue persists one assignment row per future slot (the per-delivery
      // shuffle-bag cache); the immediate delivery is recorded at `now`. Default
      // quiet hours 22:00-07:00 leave 07:00-22:00 active, so from 20:00 the
      // hourly slots are 20:00 and 21:00; the 20:00 slot shares its row with the
      // immediate -> 2 distinct rows.
      final allEntries = await history.listForDay(DateTime(2026, 3, 10));
      expect(allEntries, hasLength(2));
      expect(
        allEntries.where((entry) => entry.deliveredAt == now),
        hasLength(1),
      );
    });

    test('today-layer assignments are recorded even without immediate',
        () async {
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: false,
      );

      // No immediate delivery, but the pre-rolled queue still writes this day's
      // future slot assignments. Hourly cadence over the 07:00-21:00 window
      // would be 13 slots, but the 7-day runway cap trims each day to 7.
      final todayEntries = await history.listForDay(DateTime(2026, 3, 10));
      expect(todayEntries, hasLength(7));
      expect(
        todayEntries.every((entry) => entry.deliveredAt.day == 10),
        isTrue,
      );
    });

    test('two-day gap: scheduled notifications span multiple days', () async {
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: true,
      );

      final quoteEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList();

      final scheduledDays = quoteEvents.map((e) => e.scheduledAt.day).toSet();
      expect(
        scheduledDays.length,
        greaterThan(1),
        reason: 'notifications at 60-min intervals should span multiple days',
      );
    });

    test('rebuilding at exactly a slot time reuses cached assignment', () async {
      // Schedule at 07:30, creating an 08:00 assignment.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 7, 30),
        showImmediate: false,
      );

      final beforeRebuild = await history.listForDay(DateTime(2026, 3, 10));
      expect(beforeRebuild, hasLength(7));

      // Rebuild at exactly 08:00:00 — the 08:00 slot must be reused, not
      // recreated, so the history count stays the same.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: false,
      );

      final afterRebuild = await history.listForDay(DateTime(2026, 3, 10));
      expect(afterRebuild, hasLength(7));
    });
  });
}
