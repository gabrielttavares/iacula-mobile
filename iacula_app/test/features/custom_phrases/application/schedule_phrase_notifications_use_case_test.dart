import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/notifications/domain/services/notification_budget.dart';

class _FakeScheduler implements NotificationSchedulerRepository {
  final List<({int id, ReminderEvent event})> scheduledEvents = [];
  final List<int> cancelledIds = [];

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    scheduledEvents.add((id: id, event: event));
  }

  @override
  Future<void> cancelById(int id) async {
    cancelledIds.add(id);
  }

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

class _FakeRepository implements CustomPhraseRepository {
  final List<CustomPhrase> phrases;

  _FakeRepository(this.phrases);

  @override
  Future<List<CustomPhrase>> listAll() async => phrases;

  @override
  Future<CustomPhrase?> getById(String id) async =>
      phrases.where((p) => p.id == id).firstOrNull;

  @override
  Future<void> save(CustomPhrase phrase) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

void main() {
  late _FakeScheduler scheduler;

  setUp(() {
    scheduler = _FakeScheduler();
  });

  test('schedules prayer alarm with correct route target and slug', () async {
    final prayerPhrase = CustomPhrase(
      id: 'prayer-phrase-1',
      text: 'Ave Maria',
      isActive: true,
      displayAsNotification: true,
      useFixedSchedule: true,
      prayerSlug: 'ave-maria',
      prayerTitle: 'Ave Maria',
      schedule: const PhraseSchedule(
        type: PhraseScheduleType.daily,
        times: ['09:00'],
      ),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final repository = _FakeRepository([prayerPhrase]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);

    await useCase(phraseId: 'prayer-phrase-1');

    expect(scheduler.scheduledEvents, hasLength(1));
    final scheduled = scheduler.scheduledEvents.first;
    expect(scheduled.event.routeTarget, NotificationRouteTarget.prayer);
    expect(scheduled.event.prayerSlug, 'ave-maria');
    expect(scheduled.event.title, 'Ave Maria');
    expect(scheduled.event.body, 'Hora de rezar');
    expect(scheduled.event.isAlarm, isTrue);
    expect(scheduled.event.type, ReminderEventType.customPhrase);
  });

  test('schedules free-text phrase with home route target', () async {
    final textPhrase = CustomPhrase(
      id: 'text-phrase-1',
      text: 'Lembrai-Vos',
      isActive: true,
      displayAsNotification: true,
      useFixedSchedule: true,
      schedule: const PhraseSchedule(
        type: PhraseScheduleType.daily,
        times: ['10:40'],
      ),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final repository = _FakeRepository([textPhrase]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);

    await useCase(phraseId: 'text-phrase-1');

    expect(scheduler.scheduledEvents, hasLength(1));
    final scheduled = scheduler.scheduledEvents.first;
    expect(scheduled.event.routeTarget, NotificationRouteTarget.home);
    expect(scheduled.event.prayerSlug, isNull);
    expect(scheduled.event.title, 'Frase Pessoal');
    expect(scheduled.event.body, 'Lembrai-Vos');
    expect(scheduled.event.isAlarm, isFalse);
  });

  test('does not schedule inactive prayer alarm', () async {
    final inactivePhrase = CustomPhrase(
      id: 'inactive-1',
      text: 'Ave Maria',
      isActive: false,
      displayAsNotification: true,
      useFixedSchedule: true,
      prayerSlug: 'ave-maria',
      prayerTitle: 'Ave Maria',
      schedule: const PhraseSchedule(
        type: PhraseScheduleType.daily,
        times: ['09:00'],
      ),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final repository = _FakeRepository([inactivePhrase]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);

    await useCase(phraseId: 'inactive-1');

    expect(scheduler.scheduledEvents, isEmpty);
    expect(scheduler.cancelledIds, hasLength(10));
  });

  test('cancels old notifications before scheduling new ones', () async {
    final phrase = CustomPhrase(
      id: 'phrase-1',
      text: 'Ave Maria',
      isActive: true,
      displayAsNotification: true,
      useFixedSchedule: true,
      prayerSlug: 'ave-maria',
      prayerTitle: 'Ave Maria',
      schedule: const PhraseSchedule(
        type: PhraseScheduleType.daily,
        times: ['09:00'],
      ),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final repository = _FakeRepository([phrase]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);

    await useCase(phraseId: 'phrase-1');

    expect(scheduler.cancelledIds, hasLength(10));
    expect(scheduler.scheduledEvents, hasLength(1));
  });

  CustomPhrase _dailyPhrase(String id, String time) => CustomPhrase(
        id: id,
        text: 'Frase $id',
        isActive: true,
        displayAsNotification: true,
        useFixedSchedule: true,
        schedule: PhraseSchedule(
          type: PhraseScheduleType.daily,
          times: [time],
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

  test('stops scheduling once the shared budget is exhausted', () async {
    final repository = _FakeRepository([
      _dailyPhrase('a', '08:00'),
      _dailyPhrase('b', '09:00'),
      _dailyPhrase('c', '10:00'),
    ]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);
    final budget = NotificationBudget(capacity: 2);

    await useCase(budget: budget);

    // Only 2 of the 3 phrases get a slot; the budget is fully consumed.
    expect(scheduler.scheduledEvents, hasLength(2));
    expect(budget.remaining, 0);
    // Cancellation of stale ids still runs for every phrase (3 × 10).
    expect(scheduler.cancelledIds, hasLength(30));
  });

  test('without a budget, scheduling is unbounded (back-compat)', () async {
    final repository = _FakeRepository([
      _dailyPhrase('a', '08:00'),
      _dailyPhrase('b', '09:00'),
      _dailyPhrase('c', '10:00'),
    ]);
    final useCase = SchedulePhraseNotificationsUseCase(scheduler, repository);

    await useCase();

    expect(scheduler.scheduledEvents, hasLength(3));
  });
}
