import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../../core/storage/isar/isar_store.dart';
import '../../../../core/storage/isar/journal_entry_doc.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

final class IsarJournalRepository implements JournalRepository {
  IsarJournalRepository({required this.store});

  final IsarStore store;

  @override
  Future<List<JournalEntry>> listAll() async {
    final isar = await store.isar;
    final docs = await isar.journalEntryDocs
        .where()
        .filter()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
    return docs.map(_toEntry).toList();
  }

  @override
  Future<JournalEntry?> getById(String id) async {
    final isar = await store.isar;
    final doc = await isar.journalEntryDocs
        .where()
        .entryIdEqualTo(id)
        .findFirst();
    return doc != null ? _toEntry(doc) : null;
  }

  @override
  Future<void> save(JournalEntry entry) async {
    final isar = await store.isar;
    final doc = JournalEntryDoc()
      ..entryId = entry.id
      ..title = entry.title
      ..body = entry.body
      ..tagsJson = jsonEncode(entry.tags)
      ..mood = entry.mood?.name
      ..liturgicalSeason = entry.liturgicalSeason
      ..createdAt = entry.createdAt
      ..updatedAt = entry.updatedAt
      ..deletedAt = entry.deletedAt
      ..isDirty = true;

    await isar.writeTxn(() => isar.journalEntryDocs.put(doc));
  }

  @override
  Future<void> delete(String id) async {
    final isar = await store.isar;
    final doc = await isar.journalEntryDocs
        .where()
        .entryIdEqualTo(id)
        .findFirst();
    if (doc != null) {
      doc.deletedAt = DateTime.now();
      doc.isDirty = true;
      await isar.writeTxn(() => isar.journalEntryDocs.put(doc));
    }
  }

  @override
  Future<List<JournalEntry>> search(String query) async {
    final all = await listAll();
    final lower = query.toLowerCase();
    return all
        .where(
          (e) =>
              (e.title?.toLowerCase().contains(lower) ?? false) ||
              e.body.toLowerCase().contains(lower) ||
              e.tags.any((t) => t.toLowerCase().contains(lower)),
        )
        .toList();
  }

  JournalEntry _toEntry(JournalEntryDoc doc) {
    final tags = (jsonDecode(doc.tagsJson) as List).cast<String>();
    return JournalEntry(
      id: doc.entryId,
      title: doc.title,
      body: doc.body,
      tags: tags,
      mood: doc.mood != null ? JournalMood.values.byName(doc.mood!) : null,
      liturgicalSeason: doc.liturgicalSeason,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      deletedAt: doc.deletedAt,
    );
  }
}
