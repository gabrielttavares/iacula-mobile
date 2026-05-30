import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayer_activity/application/prayer_activity_logger.dart';
import 'package:iacula_app/features/prayer_activity/domain/entities/prayer_activity_entry.dart';
import 'package:iacula_app/features/prayer_activity/domain/repositories/prayer_activity_repository.dart';

final class _FakeNotificationSchedulerRepository
    implements NotificationSchedulerRepository {
  final _controller = StreamController<NotificationActionEvent>.broadcast();
  final List<ReminderEvent> scheduled = [];
  final List<int> cancelledIds = [];

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelByType(ReminderEventType type) async {}

  @override
  Future<void> schedule(ReminderEvent event) async {
    scheduled.add(event);
  }

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    scheduled.add(event.copyWith(scheduledId: id));
  }

  @override
  Future<void> showNow(int id, ReminderEvent event) async {
    scheduled.add(event.copyWith(scheduledId: id));
  }

  @override
  Future<List<int>> pendingNotificationIds() async => [];

  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async => null;

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  @override
  Future<bool?> requestExactAlarmsPermission() async => true;

  @override
  void resetScheduleTelemetry() {}

  @override
  Future<ShortIntervalReliability> evaluateShortIntervalReliability({
    required bool notificationsEnabled,
    required int intervalMinutes,
  }) async {
    return ShortIntervalReliability.ok;
  }
}

void main() {
  test(
    'does not store quote history when opening quote notification',
    () async {
      final scheduler = _FakeNotificationSchedulerRepository();
      final useCase = HandleNotificationActionUseCase(scheduler);

      final shouldOpen = await useCase.call(
        NotificationActionEvent(
          actionId: NotificationActionEvent.openAction,
          event: ReminderEvent(
            type: ReminderEventType.quoteInterval,
            title: 'Iacula',
            body: 'Permanecei em mim.',
            scheduledAt: DateTime(2026, 2, 24, 10),
            withVibration: true,
            isAlarm: false,
            routeTarget: NotificationRouteTarget.home,
          ),
        ),
      );

      expect(shouldOpen, isTrue);
    },
  );

  test('snooze one hour reschedules without opening app', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);
    final before = DateTime.now();

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.snooze1hAction,
        event: ReminderEvent(
          type: ReminderEventType.angelusNoon,
          title: 'Angelus',
          body: 'Hora de rezar o Angelus.',
          scheduledAt: DateTime(2026, 2, 24, 12),
          withVibration: true,
          isAlarm: true,
          routeTarget: NotificationRouteTarget.prayer,
        ),
      ),
    );

    expect(shouldOpen, isFalse);
    expect(scheduler.scheduled, hasLength(1));
    final snoozed = scheduler.scheduled.single;
    expect(snoozed.repeatDaily, isFalse);
    expect(snoozed.snoozeCount, 1);
    expect(
      snoozed.scheduledAt.difference(before),
      greaterThanOrEqualTo(const Duration(minutes: 59, seconds: 59)),
    );
    expect(
      snoozed.scheduledAt.difference(before),
      lessThanOrEqualTo(const Duration(hours: 1, seconds: 1)),
    );
  });

  test('dismiss action is treated as implicit one-hour snooze', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.dismissAction,
        event: ReminderEvent(
          type: ReminderEventType.quoteInterval,
          title: 'Iacula',
          body: 'Permanecei em mim.',
          scheduledAt: DateTime(2026, 2, 24, 10),
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.home,
          snoozeCount: 1,
        ),
      ),
    );

    expect(shouldOpen, isFalse);
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.snoozeCount, 2);
  });

  test('season transition reschedules Angelus as Regina Caeli', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: null,
        event: ReminderEvent(
          type: ReminderEventType.seasonTransition,
          title: 'Season Transition',
          body: '',
          scheduledAt: DateTime(2026, 4, 5, 0, 0),
          withVibration: false,
          isAlarm: false,
          repeatDaily: false,
          routeTarget: NotificationRouteTarget.home,
          prayerSlug: 'regina-coeli',
        ),
      ),
    );

    expect(shouldOpen, isFalse);
    expect(scheduler.cancelledIds, contains(200));

    final angelusReschedule = scheduler.scheduled.where(
      (e) => e.type == ReminderEventType.angelusNoon,
    );
    expect(angelusReschedule, hasLength(1));
    expect(angelusReschedule.first.prayerSlug, 'regina-coeli');
    expect(angelusReschedule.first.title, 'Regina Caeli');
    expect(angelusReschedule.first.body, 'Hora de rezar a Regina Caeli.');
    expect(angelusReschedule.first.repeatDaily, isTrue);
    expect(angelusReschedule.first.isAlarm, isTrue);
  });

  test('season transition reschedules Regina Caeli back to Angelus', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: null,
        event: ReminderEvent(
          type: ReminderEventType.seasonTransition,
          title: 'Season Transition',
          body: '',
          scheduledAt: DateTime(2026, 5, 25, 0, 0),
          withVibration: false,
          isAlarm: false,
          repeatDaily: false,
          routeTarget: NotificationRouteTarget.home,
          prayerSlug: 'angelus',
        ),
      ),
    );

    expect(shouldOpen, isFalse);
    expect(scheduler.cancelledIds, contains(200));

    final angelusReschedule = scheduler.scheduled.where(
      (e) => e.type == ReminderEventType.angelusNoon,
    );
    expect(angelusReschedule, hasLength(1));
    expect(angelusReschedule.first.prayerSlug, 'angelus');
    expect(angelusReschedule.first.title, 'Angelus');
    expect(angelusReschedule.first.body, 'Hora de rezar o Angelus.');
    expect(angelusReschedule.first.repeatDaily, isTrue);
  });

  test('does not reschedule after three consecutive snoozes', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.snooze1hAction,
        event: ReminderEvent(
          type: ReminderEventType.quoteInterval,
          title: 'Iacula',
          body: 'Permanecei em mim.',
          scheduledAt: DateTime(2026, 2, 24, 10),
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.home,
          snoozeCount: 3,
        ),
      ),
    );

    expect(shouldOpen, isFalse);
    expect(scheduler.scheduled, isEmpty);
  });

  test('Rezei records today\'s prayer and opens the app', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final activityRepo = _FakePrayerActivityRepository();
    final useCase = HandleNotificationActionUseCase(
      scheduler,
      prayerActivityLogger: PrayerActivityLogger(repository: activityRepo),
    );

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.rezeiAction,
        event: ReminderEvent(
          type: ReminderEventType.angelusNoon,
          title: 'Angelus',
          body: 'Hora de rezar o Angelus.',
          scheduledAt: DateTime(2026, 2, 24, 12),
          withVibration: true,
          isAlarm: true,
          routeTarget: NotificationRouteTarget.prayer,
        ),
      ),
    );

    // Opens the app so the user sees the confirmation/streak.
    expect(shouldOpen, isTrue);
    // Records a prayer for today with positive duration → counts toward streak.
    expect(activityRepo.saved, hasLength(1));
    expect(activityRepo.saved.single.activityType, PrayerActivityType.prayer);
    expect(activityRepo.saved.single.durationSeconds, greaterThan(0));
    // It does NOT snooze/reschedule.
    expect(scheduler.scheduled, isEmpty);
  });

  test('Rezei without a logger still opens the app (no crash)', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.rezeiAction,
        event: ReminderEvent(
          type: ReminderEventType.angelusNoon,
          title: 'Angelus',
          body: 'Hora de rezar o Angelus.',
          scheduledAt: DateTime(2026, 2, 24, 12),
          withVibration: true,
          isAlarm: true,
          routeTarget: NotificationRouteTarget.prayer,
        ),
      ),
    );

    expect(shouldOpen, isTrue);
  });
}

class _FakePrayerActivityRepository implements PrayerActivityRepository {
  final List<PrayerActivityEntry> saved = [];

  @override
  Future<void> save(PrayerActivityEntry entry) async => saved.add(entry);

  @override
  Future<List<PrayerActivityEntry>> listAll() async => saved;

  @override
  Future<List<PrayerActivityEntry>> listByDateRange(
    DateTime start,
    DateTime end,
  ) async => saved;

  @override
  Future<int> totalMinutesForDate(DateTime date) async => 0;

  @override
  Future<Map<String, int>> minutesByDateRange(
    DateTime start,
    DateTime end,
  ) async => {};
}
