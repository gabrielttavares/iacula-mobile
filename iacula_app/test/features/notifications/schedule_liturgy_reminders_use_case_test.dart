import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  test('schedules only enabled modules', () async {
    final repo = InMemoryNotificationSchedulerRepository();
    final useCase = ScheduleLiturgyRemindersUseCase(repo);

    final settings = Settings.defaults.copyWith(
      laudesEnabled: true,
      vespersEnabled: false,
      complineEnabled: true,
      oraMediaEnabled: false,
      laudesTime: '06:00',
      complineTime: '21:00',
    );

    await useCase(settings, now: DateTime(2026, 2, 21, 5, 0));

    expect(repo.events.length, 2);
    expect(repo.events.any((e) => e.type == ReminderEventType.laudes), isTrue);
    expect(
      repo.events.any((e) => e.type == ReminderEventType.compline),
      isTrue,
    );
  });

  test('liturgy reminders always fire regardless of the active window',
      () async {
    // Liturgy hours are user-set fixed-time alarms (a promise that is always
    // kept), so the active notification window does not suppress them — even one
    // set to a time outside the window still schedules.
    final repo = InMemoryNotificationSchedulerRepository();
    final useCase = ScheduleLiturgyRemindersUseCase(repo);

    final settings = Settings.defaults.copyWith(
      laudesEnabled: true,
      vespersEnabled: true,
      laudesTime: '06:00',
      vespersTime: '18:00',
      // Active window 07:00-21:00 (default) excludes 06:00 Laudes, but liturgy
      // alarms ignore the window.
      quietHoursStart: '07:00',
      quietHoursEnd: '21:00',
    );

    await useCase(settings, now: DateTime(2026, 2, 21, 5, 0));

    expect(repo.events.any((e) => e.type == ReminderEventType.laudes), isTrue);
    expect(repo.events.any((e) => e.type == ReminderEventType.vespers), isTrue);
  });
}
