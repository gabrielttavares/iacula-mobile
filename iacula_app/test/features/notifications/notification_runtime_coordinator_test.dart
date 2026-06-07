import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/services/notification_runtime_coordinator.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  late _FakeRebuildDelegate delegate;
  late NotificationRuntimeCoordinator coordinator;

  Settings enabledSettings({int intervalMinutes = 30}) =>
      Settings.defaults.copyWith(
        onboardingCompleted: true,
        notificationsEnabled: true,
        intervalMinutes: intervalMinutes,
      );

  Settings disabledSettings() => Settings.defaults.copyWith(
        onboardingCompleted: true,
        notificationsEnabled: false,
      );

  Settings onboardingIncompleteSettings() => Settings.defaults.copyWith(
        onboardingCompleted: false,
        notificationsEnabled: true,
      );

  setUp(() {
    delegate = _FakeRebuildDelegate();
    coordinator = NotificationRuntimeCoordinator(
      loadSettings: () async => enabledSettings(),
      rebuild: delegate.rebuild,
      pendingQuoteIds: delegate.pendingQuoteIds,
      refreshWidget: delegate.refreshWidget,
      cancelAll: delegate.cancelAll,
    );
  });

  group('handleAppResume', () {
    test('rebuilds when no pending quote IDs exist', () async {
      delegate.nextPendingIds = [];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 1);
    });

    test('skips rebuild when pending quote IDs exist', () async {
      delegate.nextPendingIds = [9000, 9001, 9002];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 0);
    });

    test('skips rebuild when mid-queue quote IDs exist', () async {
      delegate.nextPendingIds = [9050, 9051];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 0);
    });

    test('skips rebuild when only the last queue slot remains', () async {
      // After most of the pre-rolled one-shots have fired, the OS may hold only
      // the tail slot. That single high id in the quote block (9000..9063) must
      // still count as "quotes exist" so a resume does not trigger a full
      // rebuild.
      const lastQuoteSlotId = 9000 + 63;
      delegate.nextPendingIds = [lastQuoteSlotId];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 0);
    });

    test('rebuilds when pending IDs are all outside the quote range', () async {
      // An id just past the contiguous quote block is not a quote, so the app
      // still has no live quotes and must rebuild — the range check must be
      // bounded on both ends. Expressed relative to the block size so it stays
      // correct if the block grows.
      const pastBlockId = ScheduleCoreRemindersUseCase.quoteScheduleIdBase +
          ScheduleCoreRemindersUseCase.quoteIdBlockSize +
          1;
      delegate.nextPendingIds = [200, 8999, pastBlockId];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 1);
    });

    test('throttles rebuild to one per 120 seconds', () async {
      delegate.nextPendingIds = [];

      await coordinator.handleAppResume();
      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 1);
    });

    test('refreshes widget on resume', () async {
      delegate.nextPendingIds = [9000];

      await coordinator.handleAppResume();

      expect(delegate.refreshWidgetCalls, 1);
    });

    test('skips rebuild when onboarding is incomplete', () async {
      coordinator = NotificationRuntimeCoordinator(
        loadSettings: () async => onboardingIncompleteSettings(),
        rebuild: delegate.rebuild,
        pendingQuoteIds: delegate.pendingQuoteIds,
        refreshWidget: delegate.refreshWidget,
        cancelAll: delegate.cancelAll,
      );
      delegate.nextPendingIds = [];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 0);
    });

    test('skips rebuild when notifications disabled', () async {
      coordinator = NotificationRuntimeCoordinator(
        loadSettings: () async => disabledSettings(),
        rebuild: delegate.rebuild,
        pendingQuoteIds: delegate.pendingQuoteIds,
        refreshWidget: delegate.refreshWidget,
        cancelAll: delegate.cancelAll,
      );
      delegate.nextPendingIds = [];

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 0);
    });
  });

  group('handleSettingsSave', () {
    test('rebuilds notifications with new settings', () async {
      final settings = enabledSettings(intervalMinutes: 60);

      await coordinator.handleSettingsSave(
        settings,
        isEasterSeason: false,
        showImmediate: false,
      );

      expect(delegate.rebuildCalls, 1);
      expect(delegate.lastRebuildSettings?.intervalMinutes, 60);
    });

    test('cancels all when notifications are disabled', () async {
      await coordinator.handleSettingsSave(
        disabledSettings(),
        isEasterSeason: false,
        showImmediate: false,
      );

      expect(delegate.cancelAllCalls, 1);
      expect(delegate.rebuildCalls, 0);
    });

    test('passes showImmediate and isEasterSeason through', () async {
      await coordinator.handleSettingsSave(
        enabledSettings(),
        isEasterSeason: true,
        showImmediate: true,
      );

      expect(delegate.lastIsEasterSeason, isTrue);
      expect(delegate.lastShowImmediate, isTrue);
    });
  });

  group('handleAppLaunch', () {
    test('delegates to handleAppResume behavior', () async {
      delegate.nextPendingIds = [];

      await coordinator.handleAppLaunch();

      expect(delegate.rebuildCalls, 1);
      expect(delegate.refreshWidgetCalls, 1);
    });
  });

  group('health check Easter season', () {
    test('passes correct isEasterSeason when rebuilding during Easter', () async {
      // 2026 Easter: April 5 – Pentecost: May 24
      final easterDate = DateTime(2026, 4, 10, 12, 0);

      delegate = _FakeRebuildDelegate();
      delegate.nextPendingIds = [];

      coordinator = NotificationRuntimeCoordinator(
        loadSettings: () async => enabledSettings(),
        rebuild: delegate.rebuild,
        pendingQuoteIds: delegate.pendingQuoteIds,
        refreshWidget: delegate.refreshWidget,
        cancelAll: delegate.cancelAll,
        now: easterDate,
      );

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 1);
      expect(delegate.lastIsEasterSeason, isTrue);
    });

    test('passes isEasterSeason false when rebuilding outside Easter', () async {
      final ordinaryDate = DateTime(2026, 2, 15, 12, 0);

      delegate = _FakeRebuildDelegate();
      delegate.nextPendingIds = [];

      coordinator = NotificationRuntimeCoordinator(
        loadSettings: () async => enabledSettings(),
        rebuild: delegate.rebuild,
        pendingQuoteIds: delegate.pendingQuoteIds,
        refreshWidget: delegate.refreshWidget,
        cancelAll: delegate.cancelAll,
        now: ordinaryDate,
      );

      await coordinator.handleAppResume();

      expect(delegate.rebuildCalls, 1);
      expect(delegate.lastIsEasterSeason, isFalse);
    });
  });
}

final class _FakeRebuildDelegate {
  int rebuildCalls = 0;
  int refreshWidgetCalls = 0;
  int cancelAllCalls = 0;
  List<int> nextPendingIds = [];
  Settings? lastRebuildSettings;
  bool? lastIsEasterSeason;
  bool? lastShowImmediate;

  Future<void> rebuild(
    Settings settings, {
    required bool isEasterSeason,
    required bool showImmediate,
  }) async {
    rebuildCalls++;
    lastRebuildSettings = settings;
    lastIsEasterSeason = isEasterSeason;
    lastShowImmediate = showImmediate;
  }

  Future<List<int>> pendingQuoteIds() async => nextPendingIds;

  Future<void> refreshWidget() async {
    refreshWidgetCalls++;
  }

  Future<void> cancelAll() async {
    cancelAllCalls++;
  }
}
