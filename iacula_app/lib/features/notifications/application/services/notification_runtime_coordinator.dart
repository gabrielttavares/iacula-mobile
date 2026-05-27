import 'package:flutter/foundation.dart';

import '../../../liturgical/domain/easter_calculator.dart';
import '../../../settings/domain/entities/settings.dart';
import '../use_cases/schedule_core_reminders_use_case.dart';

typedef SettingsLoader = Future<Settings> Function();
typedef NotificationRebuilder = Future<void> Function(
  Settings settings, {
  required bool isEasterSeason,
  required bool showImmediate,
});
typedef PendingQuoteIdsFetcher = Future<List<int>> Function();
typedef WidgetRefresher = Future<void> Function();
typedef NotificationCanceller = Future<void> Function();
typedef Clock = DateTime Function();

final class NotificationRuntimeCoordinator {
  NotificationRuntimeCoordinator({
    required SettingsLoader loadSettings,
    required NotificationRebuilder rebuild,
    required PendingQuoteIdsFetcher pendingQuoteIds,
    required WidgetRefresher refreshWidget,
    required NotificationCanceller cancelAll,
    DateTime? now,
  })  : _loadSettings = loadSettings,
       _rebuild = rebuild,
       _pendingQuoteIds = pendingQuoteIds,
       _refreshWidget = refreshWidget,
       _cancelAll = cancelAll,
       _fixedNow = now;

  final SettingsLoader _loadSettings;
  final NotificationRebuilder _rebuild;
  final PendingQuoteIdsFetcher _pendingQuoteIds;
  final WidgetRefresher _refreshWidget;
  final NotificationCanceller _cancelAll;
  final DateTime? _fixedNow;

  DateTime? _lastRebuildTime;

  Future<void> handleAppLaunch() async {
    await _healthCheckAndRebuildIfNeeded();
    await _refreshWidget();
  }

  Future<void> handleAppResume() async {
    await _healthCheckAndRebuildIfNeeded();
    await _refreshWidget();
  }

  Future<void> handleSettingsSave(
    Settings settings, {
    required bool isEasterSeason,
    required bool showImmediate,
  }) async {
    if (!settings.notificationsEnabled) {
      await _cancelAll();
      return;
    }

    await _rebuild(
      settings,
      isEasterSeason: isEasterSeason,
      showImmediate: showImmediate,
    );
    _lastRebuildTime = DateTime.now();
  }

  Future<void> _healthCheckAndRebuildIfNeeded() async {
    final now = _fixedNow ?? DateTime.now();
    if (_lastRebuildTime != null &&
        now.difference(_lastRebuildTime!).inSeconds < 120) {
      return;
    }

    final settings = await _loadSettings();
    if (!settings.onboardingCompleted || !settings.notificationsEnabled) {
      return;
    }

    final pendingIds = await _pendingQuoteIds();
    final hasQuotes = pendingIds.any(
      (id) =>
          id >= ScheduleCoreRemindersUseCase.quoteScheduleIdBase &&
          id <
              ScheduleCoreRemindersUseCase.quoteScheduleIdBase +
                  ScheduleCoreRemindersUseCase.maxQueuedQuoteReminders,
    );

    if (hasQuotes) return;

    debugPrint(
      '[NotificationRuntimeCoordinator] No pending quotes; rebuilding.',
    );

    await _rebuild(
      settings,
      isEasterSeason: EasterCalculator.isWithinEasterSeason(now),
      showImmediate: false,
    );
    _lastRebuildTime = now;
  }
}
