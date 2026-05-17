import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/app/app.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/notifications/presentation/notification_detail_screen.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_collection.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_detail.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_content_repository.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_catalog_detail_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

/// Simulates warm resume: user taps notification while app is in background.
/// Event arrives via the actions stream after the app is fully initialized.
final class _WarmResumeScheduler implements NotificationSchedulerRepository {
  _WarmResumeScheduler(this.event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.add(NotificationActionEvent(actionId: null, event: event));
      });
    });
  }

  final ReminderEvent event;
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;
  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async => null;
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
  Future<List<int>> pendingNotificationIds() async => const [];
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

/// Simulates cold launch: app was killed, user tapped notification to open it.
/// Event comes from getLaunchNotificationAction(), not the stream.
final class _ColdLaunchScheduler implements NotificationSchedulerRepository {
  _ColdLaunchScheduler(this.launchEvent);

  final NotificationActionEvent launchEvent;
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
  Future<List<int>> pendingNotificationIds() async => const [];
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

/// Simulates no notification tap — normal app launch.
final class _NoNotificationScheduler implements NotificationSchedulerRepository {
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;
  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async => null;
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
  Future<List<int>> pendingNotificationIds() async => const [];
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

  void emitTap(ReminderEvent event) {
    _controller.add(NotificationActionEvent(actionId: null, event: event));
  }
}

final class _FixedSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async =>
      Settings.defaults.copyWith(onboardingCompleted: true, language: 'pt-br');
  @override
  Future<void> save(Settings settings) async {}
}

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
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
        sectionId: 'oracoes-a-nossa-senhora',
        sectionTitle: 'Orações a Nossa Senhora',
        availableLanguages: ['pt-br', 'la'],
      ),
      PrayerCatalogEntry(
        slug: 'regina-coeli',
        title: 'Regina Caeli',
        content: 'V/. Regina cæli, lætáre, allelúia.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
        sectionId: 'oracoes-a-nossa-senhora',
        sectionTitle: 'Orações a Nossa Senhora',
        availableLanguages: ['pt-br', 'la'],
      ),
      PrayerCatalogEntry(
        slug: 'lembrai-vos',
        title: 'Lembrai-Vos',
        content: 'Lembrai-vos, ó piíssima Virgem Maria...',
        themes: ['mariano'],
        saints: ['virgem-maria'],
        sectionId: 'oracoes-a-nossa-senhora',
        sectionTitle: 'Orações a Nossa Senhora',
        availableLanguages: ['pt-br'],
      ),
    ];
  }
}

final class _FakePrayerContentRepository implements PrayerContentRepository {
  @override
  Future<PrayerCollection> loadPrayers({required String language}) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAngelusImagePath() async => null;

  @override
  Future<String?> getReginaCaeliImagePath() async => null;

  @override
  Future<PrayerDetail> loadPrayerDetail({required String slug}) async {
    return PrayerDetail(
      slug: slug,
      defaultLanguage: 'pt-br',
      titlesByLanguage: {'pt-br': slug},
      blocksByLanguage: {
        'pt-br': ['content for $slug'],
      },
    );
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  required NotificationSchedulerRepository scheduler,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationSchedulerRepositoryProvider.overrideWithValue(scheduler),
        settingsRepositoryProvider.overrideWithValue(
          _FixedSettingsRepository(),
        ),
        prayerCatalogRepositoryProvider.overrideWithValue(
          _FakePrayerCatalogRepository(),
        ),
        prayerContentRepositoryProvider.overrideWithValue(
          _FakePrayerContentRepository(),
        ),
      ],
      child: const IaculaApp(),
    ),
  );
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

ReminderEvent quoteEvent() => ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Dai-me a graça, Senhor, que eu nunca Vos ofenda.',
      scheduledAt: DateTime(2026, 5, 17, 18, 50),
      withVibration: true,
      isAlarm: false,
      routeTarget: NotificationRouteTarget.home,
      quoteTheme: 'domingo',
      quoteSeason: 'ordinary',
    );

ReminderEvent angelusEvent() => ReminderEvent(
      type: ReminderEventType.angelusNoon,
      title: 'Angelus',
      body: 'Hora de rezar o Angelus.',
      scheduledAt: DateTime(2026, 5, 17, 12, 0),
      withVibration: true,
      isAlarm: true,
      repeatDaily: true,
      routeTarget: NotificationRouteTarget.prayer,
      prayerSlug: 'angelus',
    );

ReminderEvent reginaCaeliEvent() => ReminderEvent(
      type: ReminderEventType.angelusNoon,
      title: 'Regina Caeli',
      body: 'Hora de rezar a Regina Caeli.',
      scheduledAt: DateTime(2026, 5, 17, 12, 0),
      withVibration: true,
      isAlarm: true,
      repeatDaily: true,
      routeTarget: NotificationRouteTarget.prayer,
      prayerSlug: 'regina-coeli',
    );

ReminderEvent prayerAlarmEvent() => ReminderEvent(
      type: ReminderEventType.customPhrase,
      title: 'Lembrai-Vos',
      body: 'Hora de rezar',
      scheduledAt: DateTime(2026, 5, 17, 10, 40),
      withVibration: true,
      isAlarm: true,
      repeatDaily: true,
      routeTarget: NotificationRouteTarget.prayer,
      prayerSlug: 'lembrai-vos',
    );

void main() {
  group('Warm resume (app in background, user taps notification)', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      final platformName = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

      testWidgets(
        '$platformName: quote tap → NotificationDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(tester,
                scheduler: _WarmResumeScheduler(quoteEvent()));
            expect(find.byType(NotificationDetailScreen), findsOneWidget);
            expect(
              find.text('Dai-me a graça, Senhor, que eu nunca Vos ofenda.'),
              findsWidgets,
            );
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: Angelus tap → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(tester,
                scheduler: _WarmResumeScheduler(angelusEvent()));
            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
            expect(find.text('Ângelus'), findsWidgets);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: Regina Caeli tap → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(tester,
                scheduler: _WarmResumeScheduler(reginaCaeliEvent()));
            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
            expect(find.text('Regina Caeli'), findsWidgets);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: prayer alarm tap → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(tester,
                scheduler: _WarmResumeScheduler(prayerAlarmEvent()));
            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
            expect(find.text('Lembrai-Vos'), findsWidgets);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    }
  });

  group('Cold launch (app killed, user tapped notification to open)', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      final platformName = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

      testWidgets(
        '$platformName: quote cold launch → NotificationDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(
              tester,
              scheduler: _ColdLaunchScheduler(
                NotificationActionEvent(actionId: null, event: quoteEvent()),
              ),
            );
            expect(find.byType(NotificationDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: Angelus cold launch → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(
              tester,
              scheduler: _ColdLaunchScheduler(
                NotificationActionEvent(actionId: null, event: angelusEvent()),
              ),
            );
            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: prayer alarm cold launch → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await pumpApp(
              tester,
              scheduler: _ColdLaunchScheduler(
                NotificationActionEvent(
                    actionId: null, event: prayerAlarmEvent()),
              ),
            );
            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    }
  });

  group('Late tap (app already fully loaded, user taps notification later)', () {
    Future<void> pumpUntilSettled(WidgetTester tester) async {
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      final platformName = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

      testWidgets(
        '$platformName: quote tap after app settled → NotificationDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            final scheduler = _NoNotificationScheduler();
            await pumpApp(tester, scheduler: scheduler);
            await pumpUntilSettled(tester);

            scheduler.emitTap(quoteEvent());
            await pumpUntilSettled(tester);

            expect(find.byType(NotificationDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: Angelus tap after app settled → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            final scheduler = _NoNotificationScheduler();
            await pumpApp(tester, scheduler: scheduler);
            await pumpUntilSettled(tester);

            scheduler.emitTap(angelusEvent());
            await pumpUntilSettled(tester);

            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );

      testWidgets(
        '$platformName: prayer alarm tap after app settled → PrayerCatalogDetailScreen',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            final scheduler = _NoNotificationScheduler();
            await pumpApp(tester, scheduler: scheduler);
            await pumpUntilSettled(tester);

            scheduler.emitTap(prayerAlarmEvent());
            await pumpUntilSettled(tester);

            expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    }
  });
}
