import 'package:workmanager/workmanager.dart';

abstract interface class BackgroundSyncGateway {
  Future<void> initialize();

  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
    Duration? frequency,
  });
}

final class WorkmanagerBackgroundSyncGateway implements BackgroundSyncGateway {
  const WorkmanagerBackgroundSyncGateway({required this.dispatcher});

  /// Top-level `@pragma('vm:entry-point')` function run in the background
  /// isolate (see `core/bootstrap/background_tasks.dart`).
  final void Function() dispatcher;

  @override
  Future<void> initialize() {
    return Workmanager().initialize(dispatcher, isInDebugMode: false);
  }

  @override
  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
    Duration? frequency,
  }) {
    return Workmanager().registerPeriodicTask(
      taskId,
      taskName,
      frequency: frequency,
      constraints: Constraints(
        networkType: requiresNetwork
            ? NetworkType.connected
            : NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}

final class BackgroundSyncScheduler {
  BackgroundSyncScheduler({
    required BackgroundSyncGateway gateway,
    this.notificationRearmTaskId,
    this.notificationRearmFrequency,
  }) : _gateway = gateway;

  /// Periodic task that re-arms notifications with the app closed.
  final String? notificationRearmTaskId;
  final Duration? notificationRearmFrequency;

  static const String periodicTaskId = 'iacula_sync_periodic_v1';
  static const String periodicTaskName = 'iacula.sync.periodic';
  static const String widgetTaskId = 'iacula_widget_refresh_periodic_v1';
  static const String widgetTaskName = 'iacula.widget.refresh.periodic';

  /// Runs only in the app's isolate: background isolates start without it, so
  /// work that must happen with the app closed (the notification re-arm) is
  /// dispatched directly by `backgroundTaskDispatcher` instead.
  static Future<void> Function(String task, Map<String, dynamic>? inputData)?
  _taskRunner;

  final BackgroundSyncGateway _gateway;

  static void configureTaskRunner(
    Future<void> Function(String task, Map<String, dynamic>? inputData) runner,
  ) {
    _taskRunner = runner;
  }

  static Future<void> runBackgroundTask(
    String task,
    Map<String, dynamic>? inputData,
  ) async {
    final runner = _taskRunner;
    if (runner == null) return;
    await runner(task, inputData);
  }

  Future<void> register() async {
    try {
      await _gateway.initialize();
      await _gateway.registerPeriodicTask(
        taskId: periodicTaskId,
        taskName: periodicTaskName,
        requiresNetwork: true,
      );
      await _gateway.registerPeriodicTask(
        taskId: widgetTaskId,
        taskName: widgetTaskName,
        requiresNetwork: false,
      );
      final rearmTaskId = notificationRearmTaskId;
      if (rearmTaskId != null) {
        await _gateway.registerPeriodicTask(
          taskId: rearmTaskId,
          taskName: rearmTaskId,
          requiresNetwork: false,
          frequency: notificationRearmFrequency,
        );
      }
    } catch (_) {
      // Background scheduling is best-effort and may be unavailable in tests/dev runtimes.
    }
  }
}
