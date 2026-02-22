abstract interface class SyncOrchestrator {
  Future<void> syncAll();
  Future<void> syncModule(String module);
}
