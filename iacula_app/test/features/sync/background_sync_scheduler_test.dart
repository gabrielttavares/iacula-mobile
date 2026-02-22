import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/sync/infrastructure/services/background_sync_scheduler.dart';

void main() {
  test('registers periodic sync with connected network constraint', () async {
    final gateway = _FakeBackgroundSyncGateway();
    final scheduler = BackgroundSyncScheduler(gateway: gateway);

    await scheduler.register();

    expect(gateway.initializeCalls, 1);
    expect(gateway.registerCalls, 1);
    expect(gateway.lastTaskName, BackgroundSyncScheduler.periodicTaskName);
    expect(gateway.lastTaskId, BackgroundSyncScheduler.periodicTaskId);
    expect(gateway.lastRequiresNetwork, isTrue);
  });
}

final class _FakeBackgroundSyncGateway implements BackgroundSyncGateway {
  int initializeCalls = 0;
  int registerCalls = 0;

  String? lastTaskId;
  String? lastTaskName;
  bool? lastRequiresNetwork;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> registerPeriodicTask({
    required String taskId,
    required String taskName,
    required bool requiresNetwork,
  }) async {
    registerCalls += 1;
    lastTaskId = taskId;
    lastTaskName = taskName;
    lastRequiresNetwork = requiresNetwork;
  }
}
