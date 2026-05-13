import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/app/app.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
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

final class _IosResumeTapScheduler implements NotificationSchedulerRepository {
  _IosResumeTapScheduler(this.event) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.add(NotificationActionEvent(actionId: null, event: event));
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
    return const PrayerDetail(
      slug: 'angelus',
      defaultLanguage: 'pt-br',
      titlesByLanguage: {'pt-br': 'Ângelus'},
      blocksByLanguage: {
        'pt-br': ['V/. Angelus Dómini nuntiávit Maríæ.'],
      },
    );
  }
}

void main() {
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
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets(
    'iOS Angelus tap delivered on first frame still opens the prayer detail screen',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await pumpApp(
          tester,
          scheduler: _IosResumeTapScheduler(
            ReminderEvent(
              type: ReminderEventType.angelusNoon,
              title: 'Angelus',
              body: 'Hora de rezar o Angelus.',
              scheduledAt: DateTime(2026, 5, 13, 12, 0),
              withVibration: true,
              isAlarm: true,
              repeatDaily: true,
              routeTarget: NotificationRouteTarget.prayer,
              prayerSlug: 'angelus',
            ),
          ),
        );

        expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
        expect(find.text('Ângelus'), findsWidgets);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'iOS non-Angelus tap delivered on first frame keeps existing startup behavior',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await pumpApp(
          tester,
          scheduler: _IosResumeTapScheduler(
            ReminderEvent(
              type: ReminderEventType.quoteInterval,
              title: 'Iacula',
              body: 'Sede santos.',
              scheduledAt: DateTime(2026, 5, 13, 12, 0),
              withVibration: true,
              isAlarm: false,
              routeTarget: NotificationRouteTarget.home,
            ),
          ),
        );

        expect(find.byType(ShellScreen), findsWidgets);
        expect(find.byType(NotificationDetailScreen), findsNothing);
        expect(find.byType(PrayerCatalogDetailScreen), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
