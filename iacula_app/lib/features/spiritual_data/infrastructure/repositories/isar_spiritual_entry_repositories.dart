import 'package:isar/isar.dart';

import '../../../../core/storage/isar/examination_entry_doc.dart';
import '../../../../core/storage/isar/plan_of_life_entry_doc.dart';
import '../../../../core/storage/isar/prayer_intention_entry_doc.dart';
import '../../domain/entities/spiritual_entry.dart';
import '../../domain/repositories/spiritual_entry_repository.dart';
import '../storage/spiritual_data_isar_store.dart';

final class IsarPlanOfLifeSpiritualEntryRepository implements SpiritualEntryRepository {
  IsarPlanOfLifeSpiritualEntryRepository(this._store);

  final SpiritualDataIsarStore _store;

  @override
  SpiritualModule get module => SpiritualModule.planOfLife;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async {
    final isar = await _store.isar;
    final docs = await isar.planOfLifeEntryDocs.where().findAll();
    return docs
        .map(_fromDoc)
        .where((entry) => includeDeleted || entry.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<SpiritualEntry>> listDirty() async {
    final entries = await listLocal(includeDeleted: true);
    return entries.where((entry) => entry.isDirty).toList(growable: false);
  }

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.planOfLifeEntryDocs.getByEntryId(entry.id);
      final doc = existing ?? PlanOfLifeEntryDoc()..entryId = entry.id;
      _applyToDoc(doc, entry);
      await isar.planOfLifeEntryDocs.putByEntryId(doc);
    });
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      for (final entry in entries) {
        final existing = await isar.planOfLifeEntryDocs.getByEntryId(entry.id);
        final doc = existing ?? PlanOfLifeEntryDoc()..entryId = entry.id;
        _applyToDoc(doc, entry);
        await isar.planOfLifeEntryDocs.putByEntryId(doc);
      }
    });
  }

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.planOfLifeEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.deletedAt = deletedAt;
      existing.updatedAt = deletedAt;
      existing.isDirty = true;
      await isar.planOfLifeEntryDocs.putByEntryId(existing);
    });
  }

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.planOfLifeEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.isDirty = false;
      existing.lastSyncedAt = syncedAt;
      await isar.planOfLifeEntryDocs.putByEntryId(existing);
    });
  }

  SpiritualEntry _fromDoc(PlanOfLifeEntryDoc doc) {
    return SpiritualEntry(
      id: doc.entryId,
      module: module,
      userId: doc.userId,
      title: doc.title,
      body: doc.body,
      scheduleJson: doc.scheduleJson,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      deletedAt: doc.deletedAt,
      isDirty: doc.isDirty,
      lastSyncedAt: doc.lastSyncedAt,
    );
  }

  void _applyToDoc(PlanOfLifeEntryDoc doc, SpiritualEntry entry) {
    doc.userId = entry.userId;
    doc.title = entry.title;
    doc.body = entry.body;
    doc.scheduleJson = entry.scheduleJson;
    doc.createdAt = entry.createdAt;
    doc.updatedAt = entry.updatedAt;
    doc.deletedAt = entry.deletedAt;
    doc.isDirty = entry.isDirty;
    doc.lastSyncedAt = entry.lastSyncedAt;
  }
}

final class IsarExaminationSpiritualEntryRepository implements SpiritualEntryRepository {
  IsarExaminationSpiritualEntryRepository(this._store);

  final SpiritualDataIsarStore _store;

  @override
  SpiritualModule get module => SpiritualModule.examination;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async {
    final isar = await _store.isar;
    final docs = await isar.examinationEntryDocs.where().findAll();
    return docs
        .map(_fromDoc)
        .where((entry) => includeDeleted || entry.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<SpiritualEntry>> listDirty() async {
    final entries = await listLocal(includeDeleted: true);
    return entries.where((entry) => entry.isDirty).toList(growable: false);
  }

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.examinationEntryDocs.getByEntryId(entry.id);
      final doc = existing ?? ExaminationEntryDoc()..entryId = entry.id;
      _applyToDoc(doc, entry);
      await isar.examinationEntryDocs.putByEntryId(doc);
    });
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      for (final entry in entries) {
        final existing = await isar.examinationEntryDocs.getByEntryId(entry.id);
        final doc = existing ?? ExaminationEntryDoc()..entryId = entry.id;
        _applyToDoc(doc, entry);
        await isar.examinationEntryDocs.putByEntryId(doc);
      }
    });
  }

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.examinationEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.deletedAt = deletedAt;
      existing.updatedAt = deletedAt;
      existing.isDirty = true;
      await isar.examinationEntryDocs.putByEntryId(existing);
    });
  }

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.examinationEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.isDirty = false;
      existing.lastSyncedAt = syncedAt;
      await isar.examinationEntryDocs.putByEntryId(existing);
    });
  }

  SpiritualEntry _fromDoc(ExaminationEntryDoc doc) {
    return SpiritualEntry(
      id: doc.entryId,
      module: module,
      userId: doc.userId,
      title: doc.title,
      body: doc.body,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      deletedAt: doc.deletedAt,
      isDirty: doc.isDirty,
      lastSyncedAt: doc.lastSyncedAt,
    );
  }

  void _applyToDoc(ExaminationEntryDoc doc, SpiritualEntry entry) {
    doc.userId = entry.userId;
    doc.title = entry.title;
    doc.body = entry.body;
    doc.createdAt = entry.createdAt;
    doc.updatedAt = entry.updatedAt;
    doc.deletedAt = entry.deletedAt;
    doc.isDirty = entry.isDirty;
    doc.lastSyncedAt = entry.lastSyncedAt;
  }
}

final class IsarPrayerIntentionSpiritualEntryRepository implements SpiritualEntryRepository {
  IsarPrayerIntentionSpiritualEntryRepository(this._store);

  final SpiritualDataIsarStore _store;

  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async {
    final isar = await _store.isar;
    final docs = await isar.prayerIntentionEntryDocs.where().findAll();
    return docs
        .map(_fromDoc)
        .where((entry) => includeDeleted || entry.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<SpiritualEntry>> listDirty() async {
    final entries = await listLocal(includeDeleted: true);
    return entries.where((entry) => entry.isDirty).toList(growable: false);
  }

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.prayerIntentionEntryDocs.getByEntryId(entry.id);
      final doc = existing ?? PrayerIntentionEntryDoc()..entryId = entry.id;
      _applyToDoc(doc, entry);
      await isar.prayerIntentionEntryDocs.putByEntryId(doc);
    });
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      for (final entry in entries) {
        final existing = await isar.prayerIntentionEntryDocs.getByEntryId(entry.id);
        final doc = existing ?? PrayerIntentionEntryDoc()..entryId = entry.id;
        _applyToDoc(doc, entry);
        await isar.prayerIntentionEntryDocs.putByEntryId(doc);
      }
    });
  }

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.prayerIntentionEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.deletedAt = deletedAt;
      existing.updatedAt = deletedAt;
      existing.isDirty = true;
      await isar.prayerIntentionEntryDocs.putByEntryId(existing);
    });
  }

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.prayerIntentionEntryDocs.getByEntryId(id);
      if (existing == null) return;
      existing.isDirty = false;
      existing.lastSyncedAt = syncedAt;
      await isar.prayerIntentionEntryDocs.putByEntryId(existing);
    });
  }

  SpiritualEntry _fromDoc(PrayerIntentionEntryDoc doc) {
    return SpiritualEntry(
      id: doc.entryId,
      module: module,
      userId: doc.userId,
      title: doc.title,
      body: doc.body,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      deletedAt: doc.deletedAt,
      isDirty: doc.isDirty,
      lastSyncedAt: doc.lastSyncedAt,
    );
  }

  void _applyToDoc(PrayerIntentionEntryDoc doc, SpiritualEntry entry) {
    doc.userId = entry.userId;
    doc.title = entry.title;
    doc.body = entry.body;
    doc.createdAt = entry.createdAt;
    doc.updatedAt = entry.updatedAt;
    doc.deletedAt = entry.deletedAt;
    doc.isDirty = entry.isDirty;
    doc.lastSyncedAt = entry.lastSyncedAt;
  }
}
