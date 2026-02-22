import '../../domain/repositories/sync_orchestrator.dart';

final class SyncAllUseCase {
  const SyncAllUseCase(this._orchestrator);

  final SyncOrchestrator _orchestrator;

  Future<void> call() {
    return _orchestrator.syncAll();
  }
}
