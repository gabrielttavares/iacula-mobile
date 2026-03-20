import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

final class _InMemoryNotificationHistoryRepository
    implements NotificationHistoryRepository {
  final List<NotificationHistoryEntry> entries = [];

  @override
  Future<void> add(NotificationHistoryEntry entry) async {
    entries.removeWhere(
      (current) =>
          current.quoteText == entry.quoteText &&
          current.deliveredAt == entry.deliveredAt,
    );
    entries.add(entry);
  }

  @override
  Future<void> clearFrom(DateTime instant) async {
    final start = DateTime(instant.year, instant.month, instant.day);
    final end = start.add(const Duration(days: 1));
    entries.removeWhere(
      (entry) =>
          !entry.deliveredAt.isBefore(start) &&
          entry.deliveredAt.isBefore(end),
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async => entries;
}

void main() {
  test(
    'schedules quote history for today without depending on notification taps',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return const Quote(
                text: 'Sede santos, porque eu sou santo.',
                dayOfWeek: 1,
                theme: 'todos os santos',
                season: LiturgicalSeason.ordinary,
                imagePath: 'assets/seed/images/ordinary/1/E.jpg',
                feast: 'all-saints',
                feastName: 'todos os santos',
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      final settings = Settings.defaults.copyWith(
        intervalMinutes: 15,
        language: 'pt-br',
      );
      final now = DateTime(2026, 2, 21, 10, 0);

      await useCase(settings, now: now);

      final allQuoteEvents =
          scheduler.events
              .where((e) => e.type == ReminderEventType.quoteInterval)
              .toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      expect(allQuoteEvents.length, 65);

      expect(allQuoteEvents.first.scheduledId, 8999);
      expect(allQuoteEvents.first.scheduledAt, now);

      final scheduledEvents = allQuoteEvents.skip(1).toList();
      expect(scheduledEvents.length, 64);
      expect(scheduledEvents.first.title, 'Iacula');
      expect(scheduledEvents.first.body, 'Sede santos, porque eu sou santo.');
      expect(
        scheduledEvents.map((event) => event.scheduledId).whereType<int>().toSet(),
        hasLength(64),
      );
      expect(scheduledEvents.first.scheduledId, 9000);
      expect(scheduledEvents.last.scheduledId, 9063);
      expect(
        scheduledEvents.first.scheduledAt,
        now.add(const Duration(minutes: 15)),
      );
      expect(
        scheduledEvents.last.scheduledAt,
        now.add(const Duration(minutes: 15 * 64)),
      );

      expect(history.entries, hasLength(56));
      expect(history.entries.first.quoteText, 'Sede santos, porque eu sou santo.');
      expect(history.entries.first.theme, 'todos os santos');
      expect(history.entries.first.deliveredAt, now);
      expect(
        history.entries.last.deliveredAt,
        DateTime(2026, 2, 21, 23, 45),
      );

      final angelusEvent = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon,
      );
      expect(angelusEvent.scheduledId, 200);
    },
  );

  test('rebuilding reminders replaces future history for the same day', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return Quote(
          text: 'Quote ${now.hour}:${now.minute}',
          dayOfWeek: 1,
          theme: 'Tema',
          season: LiturgicalSeason.ordinary,
          imagePath: null,
          feast: null,
          feastName: null,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    await useCase(Settings.defaults.copyWith(intervalMinutes: 15), now: DateTime(2026, 2, 21, 10));
    final firstRunCount = history.entries.length;

    await useCase(Settings.defaults.copyWith(intervalMinutes: 30), now: DateTime(2026, 2, 21, 12));

    expect(firstRunCount, 56);
    expect(history.entries.where((entry) => !entry.deliveredAt.isBefore(DateTime(2026, 2, 21, 12))).length, 24);
  });
}
