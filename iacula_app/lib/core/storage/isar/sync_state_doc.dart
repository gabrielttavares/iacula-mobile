import 'package:isar/isar.dart';

part 'sync_state_doc.g.dart';

@collection
class SyncStateDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String module;

  DateTime? lastPullAt;
  DateTime? lastPushAt;
  String? lastError;
  DateTime? lastSyncedAt;
}
