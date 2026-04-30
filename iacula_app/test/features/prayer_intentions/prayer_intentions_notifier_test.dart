// test/features/prayer_intentions/prayer_intentions_notifier_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayer_intentions/application/prayer_intentions_notifier.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/add_intention_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/cancel_prayer_intention_reminder_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/delete_intention_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/list_intentions_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/respond_intention_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_prayer_intention_reminder_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/unrespond_intention_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/update_intention_use_case.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _InMemorySpiritualEntryRepository implements SpiritualEntryRepository {
  final List<SpiritualEntry> _entries = [];

  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      List.unmodifiable(_entries.where((e) => includeDeleted || e.deletedAt == null));

  @override
  Future<List<SpiritualEntry>> listDirty() async =>
      _entries.where((e) => e.isDirty).toList();

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    _entries.removeWhere((e) => e.id == entry.id);
    _entries.add(entry);
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    for (final entry in entries) {
      await saveLocal(entry);
    }
  }

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(deletedAt: deletedAt, isDirty: true);
    }
  }

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(isDirty: false, lastSyncedAt: syncedAt);
    }
  }
}

PrayerIntentionsNotifier _makeNotifier({
  required SpiritualEntryRepository repository,
  required InMemoryNotificationSchedulerRepository scheduler,
}) {
  return PrayerIntentionsNotifier(
    listIntentions: ListIntentionsUseCase(repository),
    addIntention: AddIntentionUseCase(repository),
    updateIntention: UpdateIntentionUseCase(repository),
    deleteIntention: DeleteIntentionUseCase(
      repository,
      CancelPrayerIntentionReminderUseCase(repository, scheduler),
    ),
    respondIntention: RespondIntentionUseCase(repository),
    unrespondIntention: UnrespondIntentionUseCase(repository),
    scheduleReminder: SchedulePrayerIntentionReminderUseCase(repository, scheduler),
    cancelReminder: CancelPrayerIntentionReminderUseCase(repository, scheduler),
  );
}

void main() {
  group('PrayerIntentionsNotifier.markResponded', () {
    test('cancels OS notifications but preserves scheduleJson so UI text remains', () async {
      final repository = _InMemorySpiritualEntryRepository();
      final scheduler = InMemoryNotificationSchedulerRepository();
      final notifier = _makeNotifier(repository: repository, scheduler: scheduler);

      final intentionId = 'test-intention-1';
      final scheduleJson = '{"type":"daily","times":["12:05"]}';

      await repository.saveLocal(
        SpiritualEntry(
          id: intentionId,
          module: SpiritualModule.prayerIntention,
          title: 'Test Intention',
          body: 'Description',
          createdAt: DateTime(2026, 4, 30),
          updatedAt: DateTime(2026, 4, 30),
          scheduleJson: scheduleJson,
          isDirty: true,
        ),
      );

      // Pre-schedule a notification so we can verify it's cancelled
      final notificationId = 500000 + (intentionId.hashCode.abs() % 499000);
      await scheduler.scheduleWithId(
        notificationId,
        ReminderEvent(
          type: ReminderEventType.prayerIntentionReminder,
          title: 'Test',
          body: 'Body',
          scheduledAt: DateTime(2026, 4, 30, 12, 5),
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.prayerIntention,
          scheduledId: notificationId,
          intentionId: intentionId,
        ),
      );
      expect(scheduler.events.any((e) => e.intentionId == intentionId), isTrue);

      await notifier.markResponded(intentionId);

      // OS notification must be cancelled
      expect(scheduler.events.any((e) => e.intentionId == intentionId), isFalse);

      // scheduleJson must be preserved so "Lembrete 12:05" stays visible in UI
      final entries = await repository.listLocal();
      final entry = entries.firstWhere((e) => e.id == intentionId);
      expect(entry.scheduleJson, scheduleJson);
    });
  });

  group('CancelPrayerIntentionReminderUseCase', () {
    test('default behavior clears scheduleJson after cancelling notifications', () async {
      final repository = _InMemorySpiritualEntryRepository();
      final scheduler = InMemoryNotificationSchedulerRepository();
      final useCase = CancelPrayerIntentionReminderUseCase(repository, scheduler);

      final intentionId = 'test-intention-2';
      final scheduleJson = '{"type":"daily","times":["08:00"]}';

      await repository.saveLocal(
        SpiritualEntry(
          id: intentionId,
          module: SpiritualModule.prayerIntention,
          title: 'Test',
          body: 'Body',
          createdAt: DateTime(2026, 4, 30),
          updatedAt: DateTime(2026, 4, 30),
          scheduleJson: scheduleJson,
          isDirty: true,
        ),
      );

      final notificationId = 500000 + (intentionId.hashCode.abs() % 499000);
      await scheduler.scheduleWithId(
        notificationId,
        ReminderEvent(
          type: ReminderEventType.prayerIntentionReminder,
          title: 'Test',
          body: 'Body',
          scheduledAt: DateTime(2026, 4, 30, 8, 0),
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.prayerIntention,
          scheduledId: notificationId,
          intentionId: intentionId,
        ),
      );

      await useCase(intentionId);

      expect(scheduler.events.any((e) => e.intentionId == intentionId), isFalse);
      final entries = await repository.listLocal();
      final entry = entries.firstWhere((e) => e.id == intentionId);
      expect(entry.scheduleJson, isNull);
    });

    test('clearSchedule false preserves scheduleJson after cancelling notifications', () async {
      final repository = _InMemorySpiritualEntryRepository();
      final scheduler = InMemoryNotificationSchedulerRepository();
      final useCase = CancelPrayerIntentionReminderUseCase(repository, scheduler);

      final intentionId = 'test-intention-3';
      final scheduleJson = '{"type":"daily","times":["08:00"]}';

      await repository.saveLocal(
        SpiritualEntry(
          id: intentionId,
          module: SpiritualModule.prayerIntention,
          title: 'Test',
          body: 'Body',
          createdAt: DateTime(2026, 4, 30),
          updatedAt: DateTime(2026, 4, 30),
          scheduleJson: scheduleJson,
          isDirty: true,
        ),
      );

      final notificationId = 500000 + (intentionId.hashCode.abs() % 499000);
      await scheduler.scheduleWithId(
        notificationId,
        ReminderEvent(
          type: ReminderEventType.prayerIntentionReminder,
          title: 'Test',
          body: 'Body',
          scheduledAt: DateTime(2026, 4, 30, 8, 0),
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.prayerIntention,
          scheduledId: notificationId,
          intentionId: intentionId,
        ),
      );

      await useCase(intentionId, clearSchedule: false);

      expect(scheduler.events.any((e) => e.intentionId == intentionId), isFalse);
      final entries = await repository.listLocal();
      final entry = entries.firstWhere((e) => e.id == intentionId);
      expect(entry.scheduleJson, scheduleJson);
    });
  });

  group('ScheduleIntentionNotificationsUseCase', () {
    test('skips entries that have already been responded to', () async {
      final repository = _InMemorySpiritualEntryRepository();
      final scheduler = InMemoryNotificationSchedulerRepository();
      final useCase = ScheduleIntentionNotificationsUseCase(scheduler, repository);

      final intentionId = 'test-intention-4';
      final scheduleJson = '{"type":"daily","times":["09:00"]}';

      await repository.saveLocal(
        SpiritualEntry(
          id: intentionId,
          module: SpiritualModule.prayerIntention,
          title: 'Responded Intention',
          body: 'Body',
          createdAt: DateTime(2026, 4, 30),
          updatedAt: DateTime(2026, 4, 30),
          scheduleJson: scheduleJson,
          respondedAt: DateTime(2026, 4, 30, 10, 0),
          isDirty: true,
        ),
      );

      await useCase(intentionId: intentionId);

      expect(
        scheduler.events.any((e) => e.intentionId == intentionId),
        isFalse,
        reason: 'Responded intentions should not have notifications scheduled',
      );
    });
  });
}
