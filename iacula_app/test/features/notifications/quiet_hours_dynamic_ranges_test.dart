import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

/// User-chosen quiet ranges produce the complementary allowed window, and the
/// scheduler confines every quote to that allowed window. The pair is written
/// as (quietStart, quietEnd) -> allowed [allowedStartMin, allowedEndMin).
void main() {
  Future<List<int>> scheduledMinutesOfDay({
    required String quietStart,
    required String quietEnd,
  }) async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = InMemoryNotificationHistoryRepository();
    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return Quote(
          text: 'q-${now.toIso8601String()}',
          dayOfWeek: (now.weekday % 7) + 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    await useCase(
      Settings.defaults.copyWith(
        intervalMinutes: 30,
        quietHoursStart: quietStart,
        quietHoursEnd: quietEnd,
      ),
      now: DateTime(2026, 5, 31, 0, 0), // midnight: today fully open ahead
      showImmediate: false,
    );

    return scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .map((e) => e.scheduledAt.hour * 60 + e.scheduledAt.minute)
        .toList();
  }

  // Each case: quiet range -> the allowed window the user expects (complement).
  final cases = <({String quietStart, String quietEnd, int allowStart, int allowEnd})>[
    // User picks "active 06:30-20:30" => quiet 20:30-06:30.
    (quietStart: '20:30', quietEnd: '06:30', allowStart: 6 * 60 + 30, allowEnd: 20 * 60 + 30),
    // User picks "active 05:30-19:30" => quiet 19:30-05:30.
    (quietStart: '19:30', quietEnd: '05:30', allowStart: 5 * 60 + 30, allowEnd: 19 * 60 + 30),
    // User picks "active 08:00-22:00" => quiet 22:00-08:00.
    (quietStart: '22:00', quietEnd: '08:00', allowStart: 8 * 60, allowEnd: 22 * 60),
  ];

  for (final c in cases) {
    test(
      'quiet ${c.quietStart}-${c.quietEnd} confines quotes to '
      '${c.allowStart ~/ 60}:${c.allowStart % 60} - '
      '${c.allowEnd ~/ 60}:${c.allowEnd % 60}',
      () async {
        final minutes = await scheduledMinutesOfDay(
          quietStart: c.quietStart,
          quietEnd: c.quietEnd,
        );
        expect(minutes, isNotEmpty);
        for (final m in minutes) {
          expect(
            m >= c.allowStart && m < c.allowEnd,
            isTrue,
            reason: 'slot at ${m ~/ 60}:${m % 60} is outside the allowed window',
          );
        }
        // And it actually fills near the window edges (not just a trivial subset).
        expect(minutes.reduce((a, b) => a < b ? a : b), c.allowStart);
      },
    );
  }
}
