import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../domain/repositories/sync_state_repository.dart';

final class InMemorySyncStateRepository implements SyncStateRepository {
  final Map<SpiritualModule, DateTime> _lastPullByModule =
      <SpiritualModule, DateTime>{};
  final Map<SpiritualModule, DateTime> _lastPushByModule =
      <SpiritualModule, DateTime>{};
  final Map<SpiritualModule, String?> _lastErrorByModule =
      <SpiritualModule, String?>{};
  final Set<String> _mergedUsers = <String>{};

  @override
  Future<DateTime?> getLastPullAt(SpiritualModule module) async {
    return _lastPullByModule[module];
  }

  @override
  Future<DateTime?> getLastPushAt(SpiritualModule module) async {
    return _lastPushByModule[module];
  }

  @override
  Future<bool> isFirstLoginMerged(String userId) async {
    return _mergedUsers.contains(userId);
  }

  @override
  Future<void> markFirstLoginMerged(String userId) async {
    _mergedUsers.add(userId);
  }

  @override
  Future<void> setLastError(SpiritualModule module, String? error) async {
    _lastErrorByModule[module] = error;
  }

  @override
  Future<void> setLastPullAt(SpiritualModule module, DateTime value) async {
    _lastPullByModule[module] = value;
  }

  @override
  Future<void> setLastPushAt(SpiritualModule module, DateTime value) async {
    _lastPushByModule[module] = value;
  }
}
