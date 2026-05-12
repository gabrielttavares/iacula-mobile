import 'background_sync_scheduler.dart';

typedef BackgroundTaskHandler = Future<void> Function();

final class BackgroundTaskRuntime {
  const BackgroundTaskRuntime({
    required BackgroundTaskHandler syncAll,
    required BackgroundTaskHandler refreshWidget,
  })  : _syncAll = syncAll,
       _refreshWidget = refreshWidget;

  final BackgroundTaskHandler _syncAll;
  final BackgroundTaskHandler _refreshWidget;

  Future<void> execute(String taskName) async {
    switch (taskName) {
      case BackgroundSyncScheduler.periodicTaskName:
        await _syncAll();
      case BackgroundSyncScheduler.widgetTaskName:
        await _refreshWidget();
    }
  }
}
