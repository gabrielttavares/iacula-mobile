import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/sync/infrastructure/services/noop_sync_orchestrator.dart';

void main() {
  test('NoopSyncOrchestrator.syncAll completes without error', () async {
    const orchestrator = NoopSyncOrchestrator();
    await expectLater(orchestrator.syncAll(), completes);
  });

  test('NoopSyncOrchestrator.syncModule completes without error', () async {
    const orchestrator = NoopSyncOrchestrator();
    await expectLater(orchestrator.syncModule('any'), completes);
  });
}
