import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/sync/infrastructure/services/background_sync_scheduler.dart';
import 'package:iacula_app/features/sync/infrastructure/services/background_task_runtime.dart';

void main() {
  test('configured background task runner is invoked', () async {
    var calls = 0;

    BackgroundSyncScheduler.configureTaskRunner((task, inputData) async {
      calls += 1;
      expect(task, BackgroundSyncScheduler.periodicTaskName);
    });

    await BackgroundSyncScheduler.runBackgroundTask(
      BackgroundSyncScheduler.periodicTaskName,
      null,
    );

    expect(calls, 1);
  });

  test('configured task runner receives widget refresh task', () async {
    var receivedWidgetTask = false;

    BackgroundSyncScheduler.configureTaskRunner((task, inputData) async {
      if (task == BackgroundSyncScheduler.widgetTaskName) {
        receivedWidgetTask = true;
      }
    });

    await BackgroundSyncScheduler.runBackgroundTask(
      BackgroundSyncScheduler.widgetTaskName,
      null,
    );

    expect(receivedWidgetTask, isTrue);
  });

  group('BackgroundTaskRuntime', () {
    test('dispatches sync task to syncAll handler', () async {
      var syncCalls = 0;
      var widgetCalls = 0;

      final runtime = BackgroundTaskRuntime(
        syncAll: () async => syncCalls++,
        refreshWidget: () async => widgetCalls++,
      );

      await runtime.execute(BackgroundSyncScheduler.periodicTaskName);

      expect(syncCalls, 1);
      expect(widgetCalls, 0);
    });

    test('dispatches widget task to refreshWidget handler', () async {
      var syncCalls = 0;
      var widgetCalls = 0;

      final runtime = BackgroundTaskRuntime(
        syncAll: () async => syncCalls++,
        refreshWidget: () async => widgetCalls++,
      );

      await runtime.execute(BackgroundSyncScheduler.widgetTaskName);

      expect(syncCalls, 0);
      expect(widgetCalls, 1);
    });

    test('ignores unknown task names safely', () async {
      var syncCalls = 0;
      var widgetCalls = 0;

      final runtime = BackgroundTaskRuntime(
        syncAll: () async => syncCalls++,
        refreshWidget: () async => widgetCalls++,
      );

      await runtime.execute('unknown.task.name');

      expect(syncCalls, 0);
      expect(widgetCalls, 0);
    });
  });
}
