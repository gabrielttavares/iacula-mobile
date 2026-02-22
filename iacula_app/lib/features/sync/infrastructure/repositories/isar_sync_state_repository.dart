import '../../../../core/storage/isar/sync_state_doc.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../domain/repositories/sync_state_repository.dart';

final class IsarSyncStateRepository implements SyncStateRepository {
  IsarSyncStateRepository(this._store);

  final SpiritualDataIsarStore _store;

  static String _moduleKey(SpiritualModule module) => 'module:${module.name}';
  static String _mergeKey(String userId) => 'first-login-merged:$userId';

  @override
  Future<DateTime?> getLastPullAt(SpiritualModule module) async {
    final doc = await _getStateDoc(_moduleKey(module));
    return doc?.lastPullAt;
  }

  @override
  Future<DateTime?> getLastPushAt(SpiritualModule module) async {
    final doc = await _getStateDoc(_moduleKey(module));
    return doc?.lastPushAt;
  }

  @override
  Future<bool> isFirstLoginMerged(String userId) async {
    final doc = await _getStateDoc(_mergeKey(userId));
    return doc?.lastSyncedAt != null;
  }

  @override
  Future<void> markFirstLoginMerged(String userId) async {
    final module = _mergeKey(userId);
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final doc = await isar.syncStateDocs.getByModule(module) ?? SyncStateDoc()
        ..module = module;
      doc.lastSyncedAt = DateTime.now().toUtc();
      await isar.syncStateDocs.putByModule(doc);
    });
  }

  @override
  Future<void> setLastError(SpiritualModule module, String? error) async {
    final moduleKey = _moduleKey(module);
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final doc =
          await isar.syncStateDocs.getByModule(moduleKey) ?? SyncStateDoc()
            ..module = moduleKey;
      doc.lastError = error;
      await isar.syncStateDocs.putByModule(doc);
    });
  }

  @override
  Future<void> setLastPullAt(SpiritualModule module, DateTime value) async {
    final moduleKey = _moduleKey(module);
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final doc =
          await isar.syncStateDocs.getByModule(moduleKey) ?? SyncStateDoc()
            ..module = moduleKey;
      doc.lastPullAt = value.toUtc();
      doc.lastSyncedAt = value.toUtc();
      await isar.syncStateDocs.putByModule(doc);
    });
  }

  @override
  Future<void> setLastPushAt(SpiritualModule module, DateTime value) async {
    final moduleKey = _moduleKey(module);
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final doc =
          await isar.syncStateDocs.getByModule(moduleKey) ?? SyncStateDoc()
            ..module = moduleKey;
      doc.lastPushAt = value.toUtc();
      doc.lastSyncedAt = value.toUtc();
      await isar.syncStateDocs.putByModule(doc);
    });
  }

  Future<SyncStateDoc?> _getStateDoc(String key) async {
    final isar = await _store.isar;
    return isar.syncStateDocs.getByModule(key);
  }
}
