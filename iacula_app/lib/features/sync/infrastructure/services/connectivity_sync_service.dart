import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/sync_orchestrator.dart';

final class ConnectivitySyncService {
  ConnectivitySyncService({
    required Connectivity connectivity,
    required SyncOrchestrator orchestrator,
  })  : _connectivity = connectivity,
        _orchestrator = orchestrator;

  final Connectivity _connectivity;
  final SyncOrchestrator _orchestrator;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  void start() {
    _sub?.cancel();
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        unawaited(_orchestrator.syncAll());
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
