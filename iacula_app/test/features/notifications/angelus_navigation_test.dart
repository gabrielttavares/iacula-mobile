import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';

class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  _FakePrayerCatalogRepository(this.entries);

  final List<PrayerCatalogEntry> entries;

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return entries;
  }
}

ReminderEvent _angelusEvent({String slug = 'angelus', String title = 'Angelus'}) {
  return ReminderEvent(
    type: ReminderEventType.angelusNoon,
    title: title,
    body: 'Hora de rezar o $title.',
    scheduledAt: DateTime(2026, 5, 11, 12, 0),
    withVibration: true,
    isAlarm: true,
    repeatDaily: true,
    routeTarget: NotificationRouteTarget.prayer,
    prayerSlug: slug,
  );
}

void main() {
  group('Bug 2: Angelus/Regina Caeli notification → prayer screen', () {
    group('payload serialization preserves prayer routing data', () {
      test('Angelus payload round-trips with correct routeTarget and prayerSlug', () {
        final event = _angelusEvent();
        final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
        final restored = NotificationActionEvent.fromPayload(payload);

        expect(restored, isNotNull);
        expect(restored!.event.type, ReminderEventType.angelusNoon);
        expect(restored.event.routeTarget, NotificationRouteTarget.prayer);
        expect(restored.event.prayerSlug, 'angelus');
        expect(restored.event.isAlarm, isTrue);
        expect(restored.event.repeatDaily, isTrue);
      });

      test('Regina Caeli payload round-trips with correct prayerSlug', () {
        final event = _angelusEvent(slug: 'regina-coeli', title: 'Regina Caeli');
        final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
        final restored = NotificationActionEvent.fromPayload(payload);

        expect(restored, isNotNull);
        expect(restored!.event.routeTarget, NotificationRouteTarget.prayer);
        expect(restored.event.prayerSlug, 'regina-coeli');
      });
    });

    group('action handler returns shouldOpen=true for notification tap', () {
      test('tapping Angelus notification (null actionId) returns shouldOpen=true', () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final handler = HandleNotificationActionUseCase(scheduler);

        final shouldOpen = await handler.call(
          NotificationActionEvent(
            actionId: null,
            event: _angelusEvent(),
          ),
        );

        expect(shouldOpen, isTrue);
      });

      test('tapping "Rezar agora" action returns shouldOpen=true', () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final handler = HandleNotificationActionUseCase(scheduler);

        final shouldOpen = await handler.call(
          NotificationActionEvent(
            actionId: NotificationActionEvent.prayNowAction,
            event: _angelusEvent(),
          ),
        );

        expect(shouldOpen, isTrue);
      });

      test('iOS default action identifier returns shouldOpen=true', () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final handler = HandleNotificationActionUseCase(scheduler);

        final shouldOpen = await handler.call(
          NotificationActionEvent(
            actionId: 'com.apple.UNNotificationDefaultActionIdentifier',
            event: _angelusEvent(),
          ),
        );

        expect(shouldOpen, isTrue);
      });

      test('snooze action returns shouldOpen=false', () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final handler = HandleNotificationActionUseCase(scheduler);

        final shouldOpen = await handler.call(
          NotificationActionEvent(
            actionId: NotificationActionEvent.snooze1hAction,
            event: _angelusEvent(),
          ),
        );

        expect(shouldOpen, isFalse);
      });
    });

    group('prayer catalog resolves Angelus and Regina Caeli slugs', () {
      const catalogWithAngelus = <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'angelus',
          title: 'Ângelus',
          content: 'V/. Angelus Dómini nuntiávit Maríæ.',
          themes: ['mariano'],
          saints: ['virgem-maria'],
          sectionId: 'oracoes-a-nossa-senhora',
          sectionTitle: 'Orações a Nossa Senhora',
          availableLanguages: ['la', 'pt-br'],
        ),
        PrayerCatalogEntry(
          slug: 'regina-coeli',
          title: 'Regina Caeli',
          content: 'V/. Regina cæli, lætáre, allelúia.',
          themes: ['mariano'],
          saints: ['virgem-maria'],
          sectionId: 'oracoes-a-nossa-senhora',
          sectionTitle: 'Orações a Nossa Senhora',
          availableLanguages: ['la', 'pt-br'],
        ),
        PrayerCatalogEntry(
          slug: 'pai-nosso',
          title: 'Pai Nosso',
          content: 'Pai nosso que estais nos céus.',
          themes: ['oracoes-comuns'],
          saints: [],
        ),
      ];

      test('getBySlug finds angelus in the catalog', () async {
        final repository = _FakePrayerCatalogRepository(catalogWithAngelus);
        final useCase = GetPrayerCatalogUseCase(repository: repository);

        final result = await useCase.getBySlug(language: 'pt-br', slug: 'angelus');

        expect(result, isNotNull);
        expect(result!.slug, 'angelus');
        expect(result.title, 'Ângelus');
      });

      test('getBySlug finds regina-coeli in the catalog', () async {
        final repository = _FakePrayerCatalogRepository(catalogWithAngelus);
        final useCase = GetPrayerCatalogUseCase(repository: repository);

        final result = await useCase.getBySlug(language: 'pt-br', slug: 'regina-coeli');

        expect(result, isNotNull);
        expect(result!.slug, 'regina-coeli');
        expect(result.title, 'Regina Caeli');
      });

      test('getBySlug returns null for unknown slug', () async {
        final repository = _FakePrayerCatalogRepository(catalogWithAngelus);
        final useCase = GetPrayerCatalogUseCase(repository: repository);

        final result = await useCase.getBySlug(language: 'pt-br', slug: 'nonexistent');

        expect(result, isNull);
      });
    });

    group('Angelus notification payload survives cold-launch scenario', () {
      test('payload created at scheduling time deserializes correctly days later', () {
        // Angelus is repeatDaily — the payload is set at scheduling time
        // and reused every day. Verify it still works.
        final originalScheduleTime = DateTime(2026, 5, 1, 12, 0);
        final event = ReminderEvent(
          type: ReminderEventType.angelusNoon,
          title: 'Angelus',
          body: 'Hora de rezar o Angelus.',
          scheduledAt: originalScheduleTime,
          withVibration: true,
          isAlarm: true,
          repeatDaily: true,
          routeTarget: NotificationRouteTarget.prayer,
          prayerSlug: 'angelus',
        );

        final payload = NotificationActionEvent(actionId: null, event: event).toPayload();

        // Days later, user taps the notification
        final restored = NotificationActionEvent.fromPayload(
          payload,
          fallbackActionId: null,
        );

        expect(restored, isNotNull);
        expect(restored!.event.routeTarget, NotificationRouteTarget.prayer);
        expect(restored.event.prayerSlug, 'angelus');
        expect(restored.event.type, ReminderEventType.angelusNoon);
        // actionId null means "user tapped notification body" → should open
        expect(restored.actionId, isNull);
      });

      test('fromPayload with iOS fallback actionId still routes correctly', () {
        final event = _angelusEvent();
        final payload = NotificationActionEvent(actionId: null, event: event).toPayload();

        // iOS passes fallback action ID on notification body tap
        final restored = NotificationActionEvent.fromPayload(
          payload,
          fallbackActionId: 'com.apple.UNNotificationDefaultActionIdentifier',
        );

        expect(restored, isNotNull);
        // The iOS default action should NOT match any snooze/dismiss case
        expect(restored!.actionId, 'com.apple.UNNotificationDefaultActionIdentifier');
        expect(restored.actionId, isNot(NotificationActionEvent.snooze1hAction));
        expect(restored.actionId, isNot(NotificationActionEvent.dismissAction));
        expect(restored.actionId, isNot(NotificationActionEvent.snooze10Action));
      });
    });
  });
}
