import '../../domain/repositories/sync_orchestrator.dart';

final class NoopSyncOrchestrator implements SyncOrchestrator {
  const NoopSyncOrchestrator();

  @override
  Future<void> syncAll() async {}

  @override
  Future<void> syncModule(String module) async {}
}
