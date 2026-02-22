import '../../../spiritual_data/domain/entities/spiritual_entry.dart';

abstract interface class SyncStateRepository {
  Future<DateTime?> getLastPullAt(SpiritualModule module);
  Future<DateTime?> getLastPushAt(SpiritualModule module);
  Future<void> setLastPullAt(SpiritualModule module, DateTime value);
  Future<void> setLastPushAt(SpiritualModule module, DateTime value);
  Future<void> setLastError(SpiritualModule module, String? error);

  Future<bool> isFirstLoginMerged(String userId);
  Future<void> markFirstLoginMerged(String userId);
}
