import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
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
}

void main() {
  test('does not store quote history when opening quote notification', () async {
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
  });

  test('does not store history when snoozing an alarm', () async {
    final scheduler = _FakeNotificationSchedulerRepository();
    final useCase = HandleNotificationActionUseCase(scheduler);

    final shouldOpen = await useCase.call(
      NotificationActionEvent(
        actionId: NotificationActionEvent.snooze10Action,
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
  });
}
