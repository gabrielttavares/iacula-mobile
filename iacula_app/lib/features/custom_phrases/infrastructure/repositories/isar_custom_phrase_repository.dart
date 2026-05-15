import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../../core/storage/isar/custom_phrase_doc.dart';
import '../../../../features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../domain/entities/custom_phrase.dart';
import '../../domain/entities/phrase_schedule.dart';
import '../../domain/repositories/custom_phrase_repository.dart';

final class IsarCustomPhraseRepository implements CustomPhraseRepository {
  IsarCustomPhraseRepository(this._store);

  final SpiritualDataIsarStore _store;

  @override
  Future<List<CustomPhrase>> listAll() async {
    final isar = await _store.isar;
    final docs = await isar.customPhraseDocs.where().findAll();
    return docs.map(_toEntity).toList();
  }

  @override
  Future<CustomPhrase?> getById(String id) async {
    final isar = await _store.isar;
    final doc = await isar.customPhraseDocs.filter().phraseIdEqualTo(id).findFirst();
    return doc != null ? _toEntity(doc) : null;
  }

  @override
  Future<void> save(CustomPhrase phrase) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing =
          await isar.customPhraseDocs.filter().phraseIdEqualTo(phrase.id).findFirst();

      final doc = existing ?? CustomPhraseDoc();
      doc.phraseId = phrase.id;
      doc.text = phrase.text;
      doc.isActive = phrase.isActive;
      doc.displayOnHero = phrase.displayOnHero;
      doc.displayAsNotification = phrase.displayAsNotification;
      doc.scheduleJson = jsonEncode({
        ...phrase.schedule.toJson(),
        'useFixedSchedule': phrase.useFixedSchedule,
        if (phrase.prayerSlug != null) 'prayerSlug': phrase.prayerSlug,
        if (phrase.prayerTitle != null) 'prayerTitle': phrase.prayerTitle,
      });
      doc.createdAt = phrase.createdAt.toUtc();
      doc.updatedAt = phrase.updatedAt.toUtc();

      await isar.customPhraseDocs.put(doc);
    });
  }

  @override
  Future<void> delete(String id) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      await isar.customPhraseDocs.filter().phraseIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Stream<List<CustomPhrase>> watchAll() async* {
    final isar = await _store.isar;
    yield* isar.customPhraseDocs
        .where()
        .watch(fireImmediately: true)
        .map((docs) => docs.map(_toEntity).toList());
  }

  CustomPhrase _toEntity(CustomPhraseDoc doc) {
    final json = jsonDecode(doc.scheduleJson) as Map<String, dynamic>;
    return CustomPhrase(
      id: doc.phraseId,
      text: doc.text,
      isActive: doc.isActive,
      displayOnHero: doc.displayOnHero,
      displayAsNotification: doc.displayAsNotification,
      useFixedSchedule: json['useFixedSchedule'] as bool? ?? false,
      schedule: PhraseSchedule.fromJson(json),
      createdAt: doc.createdAt.toLocal(),
      updatedAt: doc.updatedAt.toLocal(),
      prayerSlug: json['prayerSlug'] as String?,
      prayerTitle: json['prayerTitle'] as String?,
    );
  }
}
