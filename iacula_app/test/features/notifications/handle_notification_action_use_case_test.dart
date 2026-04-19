import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';

final class _FakeNotificationSchedulerRepository
    implements NotificationSchedulerRepository {
  final _controller = StreamController<NotificationActionEvent>.broadcast();
  final List<ReminderEvent> scheduled = [];

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}

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
}
