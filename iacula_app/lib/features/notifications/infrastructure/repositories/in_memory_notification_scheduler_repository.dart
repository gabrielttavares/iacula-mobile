import 'dart:async';

import '../../domain/entities/notification_action_event.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class InMemoryNotificationSchedulerRepository implements NotificationSchedulerRepository {
  final List<ReminderEvent> _events = [];
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  List<ReminderEvent> get events => List.unmodifiable(_events);

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> schedule(ReminderEvent event) async {
    _events.removeWhere((e) => e.type == event.type);
    _events.add(event);
  }

  @override
  Future<void> cancelByType(ReminderEventType type) async {
    _events.removeWhere((e) => e.type == type);
  }

  @override
  Future<void> cancelAll() async {
    _events.clear();
  }
}
