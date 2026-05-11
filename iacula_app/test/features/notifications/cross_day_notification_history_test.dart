import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  group('Bug 1: cross-day notification history entries', () {
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

    test('scheduling at 23:00 writes history entries for today AND tomorrow', () async {
      final now = DateTime(2026, 3, 10, 23, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: now,
        showImmediate: true,
      );

      final todayEntries = await history.listForDay(DateTime(2026, 3, 10));
      final tomorrowEntries = await history.listForDay(DateTime(2026, 3, 11));

      expect(todayEntries, isNotEmpty, reason: 'should have entries for today (23:00, 23:30)');
      expect(tomorrowEntries, isNotEmpty, reason: 'should have entries for tomorrow');
    });

    test('app opened next day sees delivered notifications from overnight schedule', () async {
      // Simulate: app opened yesterday at 20:00, scheduled notifications
      final yesterday = DateTime(2026, 3, 10, 20, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: yesterday,
        showImmediate: true,
      );

      // Verify today (March 11) has entries that were pre-written
      final todayEntries = await history.listForDay(DateTime(2026, 3, 11));
      expect(
        todayEntries,
        isNotEmpty,
        reason: 'notifications scheduled yesterday should have history entries for today',
      );

      // The entries for today should span multiple hours
      final todayHours = todayEntries.map((entry) => entry.deliveredAt.hour).toSet();
      expect(
        todayHours.length,
        greaterThan(1),
        reason: 'today should have entries across multiple hours',
      );
    });

    test('rebuild preserves already-delivered entries while replacing future ones', () async {
      // First scheduling at 8:00 — writes entries for 8:00 onward
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: true,
      );

      final entriesBeforeRebuild = await history.listForDay(DateTime(2026, 3, 10));
      final deliveredBefore14 = entriesBeforeRebuild
          .where((entry) => entry.deliveredAt.isBefore(DateTime(2026, 3, 10, 14, 0)))
          .toList();

      // App reopened at 14:00 — rebuild clears future entries, reschedules
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 14, 0),
        showImmediate: false,
      );

      final entriesAfterRebuild = await history.listForDay(DateTime(2026, 3, 10));

      // Entries before 14:00 (8:00, 9:00, 10:00, 11:00, 12:00, 13:00) must survive
      final survivingEarlyEntries = entriesAfterRebuild
          .where((entry) => entry.deliveredAt.isBefore(DateTime(2026, 3, 10, 14, 0)))
          .toList();
      expect(
        survivingEarlyEntries.length,
        deliveredBefore14.length,
        reason: 'already-delivered entries must not be deleted by rebuild',
      );
    });

    test('listForDay only returns entries for the requested day', () async {
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 20, 0),
        showImmediate: true,
      );

      final mar10 = await history.listForDay(DateTime(2026, 3, 10));
      final mar11 = await history.listForDay(DateTime(2026, 3, 11));

      for (final entry in mar10) {
        expect(entry.deliveredAt.day, 10, reason: 'Mar 10 query should only return Mar 10 entries');
      }
      for (final entry in mar11) {
        expect(entry.deliveredAt.day, 11, reason: 'Mar 11 query should only return Mar 11 entries');
      }
    });

    test('two-day gap: app not opened for 2 days still has history for delivery day', () async {
      // App opened on March 10 at 08:00 with 60-min intervals
      // 64 slots = 64 hours = ~2.7 days of coverage
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 3, 10, 8, 0),
        showImmediate: true,
      );

      // User opens app on March 12 — the entries for March 11 should exist
      final mar11Entries = await history.listForDay(DateTime(2026, 3, 11));
      expect(
        mar11Entries,
        isNotEmpty,
        reason: 'notifications scheduled 2 days ago should have history for intermediate day',
      );

      // March 12 should also have entries (within the 64-slot window)
      final mar12Entries = await history.listForDay(DateTime(2026, 3, 12));
      expect(
        mar12Entries,
        isNotEmpty,
        reason: 'notifications should span into the 3rd day at 60-min intervals',
      );
    });
  });
}
