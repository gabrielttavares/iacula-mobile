import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';

/// Simulates a cold-launch scenario where the notification that launched the
/// app is returned by [getLaunchNotificationAction].
final class _ColdLaunchSchedulerRepository
    implements NotificationSchedulerRepository {
  _ColdLaunchSchedulerRepository({required this.launchEvent});

  final NotificationActionEvent? launchEvent;
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async =>
      launchEvent;

  @override
  Future<void> schedule(ReminderEvent event) async {}

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {}

  @override
  Future<void> showNow(int id, ReminderEvent event) async {}

  @override
  Future<void> cancelByType(ReminderEventType type) async {}

  @override
  Future<void> cancelById(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<List<int>> pendingNotificationIds() async => [];

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
  }) async => ShortIntervalReliability.ok;
}

class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return const [
      PrayerCatalogEntry(
        slug: 'angelus',
        title: 'Ângelus',
        content: 'V/. Angelus Dómini nuntiávit Maríæ.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
      PrayerCatalogEntry(
        slug: 'regina-coeli',
        title: 'Regina Caeli',
        content: 'V/. Regina cæli, lætáre, allelúia.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
    ];
  }
}

void main() {
  group('iOS Angelus notification tap → prayer screen (end-to-end flow)', () {
    // This simulates the EXACT sequence that happens on iOS when a user
    // taps the Angelus notification to cold-launch the app:
    //
    // 1. App starts, getLaunchNotificationAction() returns the event
    // 2. HandleNotificationActionUseCase decides shouldOpen
    // 3. The event's prayerSlug is used to look up the prayer in the catalog
    // 4. PrayerCatalogDetailScreen is pushed with the found entry
    //
    // On iOS, the actionId for a body tap is
    // 'com.apple.UNNotificationDefaultActionIdentifier'.

    ReminderEvent buildAngelusEvent({String slug = 'angelus'}) {
      return ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: slug == 'angelus' ? 'Angelus' : 'Regina Caeli',
        body: slug == 'angelus'
            ? 'Hora de rezar o Angelus.'
            : 'Hora de rezar a Regina Caeli.',
        scheduledAt: DateTime(2026, 5, 11, 12, 0),
        withVibration: true,
        isAlarm: true,
        repeatDaily: true,
        routeTarget: NotificationRouteTarget.prayer,
        prayerSlug: slug,
      );
    }

    /// Simulates what flutter_local_notifications does on iOS when the user
    /// taps the notification body (not an action button) to cold-launch.
    NotificationActionEvent simulateIOSLaunchTap(ReminderEvent event) {
      // 1. At scheduling time, the payload was serialized
      final payload = NotificationActionEvent(
        actionId: null,
        event: event,
      ).toPayload();

      // 2. On iOS cold launch, getNotificationAppLaunchDetails returns the
      //    response with actionId = null (body tap, not action button)
      //    and the serialized payload.
      final restored = NotificationActionEvent.fromPayload(
        payload,
        fallbackActionId: null,
      );

      return restored!;
    }

    /// Same as above but with the iOS default action identifier, which
    /// some iOS versions pass for body taps.
    NotificationActionEvent simulateIOSLaunchTapWithDefaultAction(
      ReminderEvent event,
    ) {
      final payload = NotificationActionEvent(
        actionId: null,
        event: event,
      ).toPayload();

      return NotificationActionEvent.fromPayload(
        payload,
        fallbackActionId: 'com.apple.UNNotificationDefaultActionIdentifier',
      )!;
    }

    test('iOS cold-launch Angelus tap: full flow reaches prayer catalog entry', () async {
      // Step 1: Simulate iOS cold launch with Angelus notification
      final angelusEvent = buildAngelusEvent(slug: 'angelus');
      final launchAction = simulateIOSLaunchTap(angelusEvent);

      final scheduler = _ColdLaunchSchedulerRepository(
        launchEvent: launchAction,
      );

      // Step 2: App calls getLaunchNotificationAction (cold launch path)
      final retrievedAction = await scheduler.getLaunchNotificationAction();
      expect(retrievedAction, isNotNull);

      // Step 3: HandleNotificationActionUseCase decides to open
      final handler = HandleNotificationActionUseCase(scheduler);
      final shouldOpen = await handler.call(retrievedAction!);
      expect(shouldOpen, isTrue, reason: 'body tap should navigate, not snooze');

      // Step 4: _pushRouteForEvent reads the event
      final routeEvent = retrievedAction.event;
      expect(routeEvent.routeTarget, NotificationRouteTarget.prayer);
      expect(routeEvent.prayerSlug, 'angelus');

      // Step 5: getBySlug resolves the prayer
      final catalogUseCase = GetPrayerCatalogUseCase(
        repository: _FakePrayerCatalogRepository(),
      );
      final catalogEntry = await catalogUseCase.getBySlug(
        language: 'pt-br',
        slug: routeEvent.prayerSlug!,
      );
      expect(catalogEntry, isNotNull, reason: 'angelus must be in catalog');
      expect(catalogEntry!.slug, 'angelus');
      expect(catalogEntry.title, 'Ângelus');
    });

    test('iOS cold-launch Regina Caeli tap: full flow reaches prayer catalog entry', () async {
      final reginaEvent = buildAngelusEvent(slug: 'regina-coeli');
      final launchAction = simulateIOSLaunchTap(reginaEvent);

      final scheduler = _ColdLaunchSchedulerRepository(
        launchEvent: launchAction,
      );

      final retrievedAction = await scheduler.getLaunchNotificationAction();
      expect(retrievedAction, isNotNull);

      final handler = HandleNotificationActionUseCase(scheduler);
      final shouldOpen = await handler.call(retrievedAction!);
      expect(shouldOpen, isTrue);

      final routeEvent = retrievedAction.event;
      expect(routeEvent.routeTarget, NotificationRouteTarget.prayer);
      expect(routeEvent.prayerSlug, 'regina-coeli');

      final catalogUseCase = GetPrayerCatalogUseCase(
        repository: _FakePrayerCatalogRepository(),
      );
      final catalogEntry = await catalogUseCase.getBySlug(
        language: 'pt-br',
        slug: routeEvent.prayerSlug!,
      );
      expect(catalogEntry, isNotNull, reason: 'regina-coeli must be in catalog');
      expect(catalogEntry!.slug, 'regina-coeli');
      expect(catalogEntry.title, 'Regina Caeli');
    });

    test('iOS body tap with UNNotificationDefaultActionIdentifier still opens prayer', () async {
      final angelusEvent = buildAngelusEvent(slug: 'angelus');
      final launchAction = simulateIOSLaunchTapWithDefaultAction(angelusEvent);

      final scheduler = _ColdLaunchSchedulerRepository(
        launchEvent: launchAction,
      );

      final retrievedAction = await scheduler.getLaunchNotificationAction();
      expect(retrievedAction, isNotNull);

      // iOS default action ID must NOT be interpreted as snooze/dismiss
      final handler = HandleNotificationActionUseCase(scheduler);
      final shouldOpen = await handler.call(retrievedAction!);
      expect(
        shouldOpen,
        isTrue,
        reason: 'com.apple.UNNotificationDefaultActionIdentifier must not match snooze/dismiss',
      );

      expect(retrievedAction.event.prayerSlug, 'angelus');
    });

    test('iOS "Rezar agora" action tap opens prayer', () async {
      final angelusEvent = buildAngelusEvent(slug: 'angelus');
      final payload = NotificationActionEvent(
        actionId: null,
        event: angelusEvent,
      ).toPayload();

      // "Rezar agora" uses the prayNowAction identifier
      final action = NotificationActionEvent.fromPayload(
        payload,
        fallbackActionId: NotificationActionEvent.prayNowAction,
      )!;

      final scheduler = _ColdLaunchSchedulerRepository(launchEvent: action);
      final handler = HandleNotificationActionUseCase(scheduler);

      final retrievedAction = await scheduler.getLaunchNotificationAction();
      final shouldOpen = await handler.call(retrievedAction!);

      expect(shouldOpen, isTrue, reason: '"Rezar agora" should open the prayer');
      expect(retrievedAction.event.prayerSlug, 'angelus');
    });

    test('iOS "Adiar 1h" action does NOT open prayer', () async {
      final angelusEvent = buildAngelusEvent(slug: 'angelus');
      final payload = NotificationActionEvent(
        actionId: null,
        event: angelusEvent,
      ).toPayload();

      // "Adiar 1h" uses the snooze1hAction identifier
      final action = NotificationActionEvent.fromPayload(
        payload,
        fallbackActionId: NotificationActionEvent.snooze1hAction,
      )!;

      final scheduler = _ColdLaunchSchedulerRepository(launchEvent: action);
      final handler = HandleNotificationActionUseCase(scheduler);

      final retrievedAction = await scheduler.getLaunchNotificationAction();
      final shouldOpen = await handler.call(retrievedAction!);

      expect(shouldOpen, isFalse, reason: '"Adiar 1h" must snooze, not navigate');
    });

    test('foreground Angelus tap via actions stream reaches prayer slug', () async {
      final angelusEvent = buildAngelusEvent(slug: 'angelus');
      final payload = NotificationActionEvent(
        actionId: null,
        event: angelusEvent,
      ).toPayload();

      // Simulate foreground tap: handleNotificationResponse calls fromPayload
      // and emits on the actions stream
      final restored = NotificationActionEvent.fromPayload(
        payload,
        fallbackActionId: null,
      )!;

      final scheduler = _ColdLaunchSchedulerRepository(launchEvent: null);
      final handler = HandleNotificationActionUseCase(scheduler);

      final shouldOpen = await handler.call(restored);
      expect(shouldOpen, isTrue);
      expect(restored.event.routeTarget, NotificationRouteTarget.prayer);
      expect(restored.event.prayerSlug, 'angelus');

      // Verify catalog lookup would succeed
      final catalogUseCase = GetPrayerCatalogUseCase(
        repository: _FakePrayerCatalogRepository(),
      );
      final entry = await catalogUseCase.getBySlug(
        language: 'pt-br',
        slug: restored.event.prayerSlug!,
      );
      expect(entry, isNotNull);
    });
  });
}
