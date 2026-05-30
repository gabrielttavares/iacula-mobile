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

    test('only the immediate notification writes a history entry', () async {
      final now = DateTime(2026, 3, 10, 20, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: now,
        showImmediate: true,
      );

      // The grid no longer predicts future rows; only the immediate delivery
      // is recorded, on `now`'s day.
      final allEntries = await history.listForDay(DateTime(2026, 3, 10));
      expect(allEntries, hasLength(1));
      expect(allEntries.single.deliveredAt, now);
    });

    test('showImmediate false writes no history entries', () async {
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: false,
      );

      final todayEntries = await history.listForDay(DateTime(2026, 3, 10));
      expect(todayEntries, isEmpty);
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
  });
}
