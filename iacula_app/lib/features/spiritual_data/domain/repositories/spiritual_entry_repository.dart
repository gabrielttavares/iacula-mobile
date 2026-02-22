import '../entities/spiritual_entry.dart';

abstract interface class SpiritualEntryRepository {
  SpiritualModule get module;
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false});
  Future<List<SpiritualEntry>> listDirty();
  Future<void> saveLocal(SpiritualEntry entry);
  Future<void> upsertMany(List<SpiritualEntry> entries);
  Future<void> markDeleted(String id, {required DateTime deletedAt});
  Future<void> markClean(String id, {required DateTime syncedAt});
}
