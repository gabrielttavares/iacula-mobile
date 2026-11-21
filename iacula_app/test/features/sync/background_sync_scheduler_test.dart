import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/sync/infrastructure/services/background_sync_scheduler.dart';

void main() {
  test('registers periodic sync and widget refresh tasks', () async {
    final gateway = _FakeBackgroundSyncGateway();
    final scheduler = BackgroundSyncScheduler(gateway: gateway);

    await scheduler.register();

    expect(gateway.initializeCalls, 1);
    expect(gateway.registerCalls, 2);
    expect(gateway.calls, [
      (
        BackgroundSyncScheduler.periodicTaskId,
        BackgroundSyncScheduler.periodicTaskName,
        true,
      ),
      (
        BackgroundSyncScheduler.widgetTaskId,
        BackgroundSyncScheduler.widgetTaskName,
        false,
      ),
    ]);
  });

  test('registers the notification re-arm task when configured', () async {
    final gateway = _FakeBackgroundSyncGateway();
    final scheduler = BackgroundSyncScheduler(
      gateway: gateway,
      notificationRearmTaskId: 'rearm',
      notificationRearmFrequency: const Duration(hours: 12),
    );

    await scheduler.register();

    expect(gateway.calls.last, ('rearm', 'rearm', false));
    expect(gateway.frequencies.last, const Duration(hours: 12));
  });
}

final class _FakeBackgroundSyncGateway implements BackgroundSyncGateway {
  int initializeCalls = 0;
  int registerCalls = 0;

  final List<(String, String, bool)> calls = [];
  final List<Duration?> frequencies = [];

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
    Duration? frequency,
  }) async {
    registerCalls += 1;
    calls.add((taskId, taskName, requiresNetwork));
    frequencies.add(frequency);
  }
}
