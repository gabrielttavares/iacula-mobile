import '../../../spiritual_data/domain/entities/spiritual_entry.dart';

abstract interface class SyncRepository {
  SpiritualModule get module;
  Future<List<SpiritualEntry>> pullChanges({required DateTime? since, required String userId});
  Future<List<SpiritualEntry>> pushChanges({required List<SpiritualEntry> localChanges, required String userId});
}
