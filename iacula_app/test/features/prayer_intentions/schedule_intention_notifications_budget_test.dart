import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/notifications/domain/services/notification_budget.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/domain/entities/intention_schedule.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

class _FakeScheduler implements NotificationSchedulerRepository {
  final List<ReminderEvent> scheduled = [];
  final List<int> cancelledIds = [];

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    scheduled.add(event);
  }

  @override
  Future<void> cancelById(int id) async => cancelledIds.add(id);

  @override
  Stream<NotificationActionEvent> get actions => const Stream.empty();
  @override
  Future<void> schedule(ReminderEvent event) async {}
  @override
  Future<void> showNow(int id, ReminderEvent event) async {}
  @override
  Future<void> cancelByType(ReminderEventType type) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<List<int>> pendingNotificationIds() async => [];
  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async => null;
}

class _FakeEntryRepository implements SpiritualEntryRepository {
  _FakeEntryRepository(this._entries);

  final List<SpiritualEntry> _entries;

  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      _entries;

  @override
  Future<List<SpiritualEntry>> listDirty() async => const [];
  @override
  Future<void> saveLocal(SpiritualEntry entry) async {}
  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {}
  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {}
  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {}
}

SpiritualEntry _dailyIntention(String id) {
  final schedule = const IntentionSchedule(
    type: IntentionScheduleType.daily,
    times: ['09:00'],
  );
  return SpiritualEntry(
    id: id,
    module: SpiritualModule.prayerIntention,
    title: 'Intenção $id',
    body: 'Reze por $id',
    scheduleJson: _encode(schedule),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

String _encode(IntentionSchedule schedule) {
  final map = schedule.toJson();
  return '{"type":"${map['type']}","times":${_jsonList(schedule.times)}}';
}

String _jsonList(List<String> items) =>
    '[${items.map((t) => '"$t"').join(',')}]';

void main() {
  test('stops scheduling intentions once the shared budget is exhausted',
      () async {
    final scheduler = _FakeScheduler();
    final repository = _FakeEntryRepository([
      _dailyIntention('a'),
      _dailyIntention('b'),
      _dailyIntention('c'),
    ]);
    final useCase = ScheduleIntentionNotificationsUseCase(scheduler, repository);
    final budget = NotificationBudget(capacity: 2);

    await useCase.call(budget: budget);

    expect(scheduler.scheduled, hasLength(2));
    expect(budget.remaining, 0);
  });

  test('without a budget, intention scheduling is unbounded (back-compat)',
      () async {
    final scheduler = _FakeScheduler();
    final repository = _FakeEntryRepository([
      _dailyIntention('a'),
      _dailyIntention('b'),
      _dailyIntention('c'),
    ]);
    final useCase = ScheduleIntentionNotificationsUseCase(scheduler, repository);

    await useCase.call();

    expect(scheduler.scheduled, hasLength(3));
  });
}
