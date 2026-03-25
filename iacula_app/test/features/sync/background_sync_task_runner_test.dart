import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/sync/infrastructure/services/background_sync_scheduler.dart';

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
}
