import 'dart:developer' as developer;
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/sync/infrastructure/services/background_sync_scheduler.dart';
import 'app_bootstrap.dart';

/// Identifier of the periodic task that re-arms notifications while the app
/// is closed. On iOS it is also the BGTaskScheduler identifier: keep it in
/// sync with `BGTaskSchedulerPermittedIdentifiers` (Info.plist) and
/// `AppDelegate.swift`.
const String notificationRearmTaskId = 'com.iacula.app.notifications.rearm';

/// How often Android runs the re-arm. iOS decides on its own, using the
/// frequency registered in AppDelegate as a lower bound.
const Duration notificationRearmFrequency = Duration(hours: 12);

/// Entry point the OS calls in a fresh background isolate. It must be a
/// top-level function marked as an entry point, or release builds strip it and
/// every background task silently does nothing.
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      if (task == notificationRearmTaskId) {
        await AppBootstrap.rearmNotificationsInBackground();
      } else {
        await BackgroundSyncScheduler.runBackgroundTask(task, inputData);
      }
      return true;
    } catch (error, stackTrace) {
      developer.log(
        'Background task "$task" failed.',
        name: 'BackgroundTasks',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  });
}
