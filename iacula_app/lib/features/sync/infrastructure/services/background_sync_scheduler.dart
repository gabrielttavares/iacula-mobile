import 'package:workmanager/workmanager.dart';

abstract interface class BackgroundSyncGateway {
  Future<void> initialize();

  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
  });
}

final class WorkmanagerBackgroundSyncGateway implements BackgroundSyncGateway {
  const WorkmanagerBackgroundSyncGateway();

  @override
  Future<void> initialize() {
    return Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
  }

  @override
  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
  }) {
    return Workmanager().registerPeriodicTask(
      taskId,
      taskName,
      constraints: Constraints(
        networkType: requiresNetwork
            ? NetworkType.connected
            : NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      return true;
    });
  }
}

final class BackgroundSyncScheduler {
  BackgroundSyncScheduler({required BackgroundSyncGateway gateway})
    : _gateway = gateway;

  static const String periodicTaskId = 'iacula_sync_periodic_v1';
  static const String periodicTaskName = 'iacula.sync.periodic';

  final BackgroundSyncGateway _gateway;

  Future<void> register() async {
    try {
      await _gateway.initialize();
      await _gateway.registerPeriodicTask(
        taskId: periodicTaskId,
        taskName: periodicTaskName,
        requiresNetwork: true,
      );
    } catch (_) {
      // Background scheduling is best-effort and may be unavailable in tests/dev runtimes.
    }
  }
}
