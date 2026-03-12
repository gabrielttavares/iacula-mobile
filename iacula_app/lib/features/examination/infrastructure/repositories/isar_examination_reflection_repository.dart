import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/isar/examination_reflection_doc.dart';
import '../../../../features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../domain/entities/examination_reflection_item.dart';
import '../../domain/repositories/examination_reflection_repository.dart';

final class IsarExaminationReflectionRepository
    implements ExaminationReflectionRepository {
  IsarExaminationReflectionRepository({
    SpiritualDataIsarStore? store,
    Future<Isar> Function()? isarProvider,
    Future<String> Function()? loadSeed,
    Uuid? uuid,
  }) : assert(store != null || isarProvider != null),
       _isarProvider = isarProvider ?? (() async => store!.isar),
       _loadSeed = loadSeed ?? (() => rootBundle.loadString(_seedAssetPath)),
       _uuid = uuid ?? const Uuid();

  static const String _seedAssetPath =
      'assets/seed/examination/reflection_questions.json';

  final Future<Isar> Function() _isarProvider;
  final Future<String> Function() _loadSeed;
  final Uuid _uuid;
  final _controller =
      StreamController<List<ExaminationReflectionItem>>.broadcast();

  @override
  Future<List<ExaminationReflectionItem>> listAll() async {
    final isar = await _isarProvider();
    final docs = await isar.examinationReflectionDocs
        .where()
        .sortBySortOrder()
        .findAll();
    return docs.map(_toEntity).toList(growable: false);
  }

  @override
  Stream<List<ExaminationReflectionItem>> watchAll() async* {
    yield await listAll();
    yield* _controller.stream;
  }

  @override
  Future<void> seedDefaultsIfEmpty() async {
    final isar = await _isarProvider();
    if (await isar.examinationReflectionDocs.count() > 0) return;

    final decoded = jsonDecode(await _loadSeed()) as List<dynamic>;
    final now = DateTime.now().toUtc();
    await isar.writeTxn(() async {
      for (final entry in decoded.cast<Map<String, dynamic>>()) {
        final doc = ExaminationReflectionDoc()
          ..reflectionId = entry['id'] as String
          ..sectionTitle = entry['section_title'] as String
          ..text = entry['text'] as String
          ..sortOrder = entry['sort_order'] as int
          ..createdAt = now
          ..updatedAt = now;
        await isar.examinationReflectionDocs.putByReflectionId(doc);
      }
    });

    _controller.add(await listAll());
  }

  @override
  Future<void> createItem({
    required String sectionTitle,
    required String text,
  }) async {
    final isar = await _isarProvider();
    final latest = await isar.examinationReflectionDocs
        .where()
        .sortBySortOrderDesc()
        .findFirst();
    final now = DateTime.now().toUtc();

    await isar.writeTxn(() async {
      final doc = ExaminationReflectionDoc()
        ..reflectionId = _uuid.v4()
        ..sectionTitle = sectionTitle
        ..text = text
        ..sortOrder = (latest?.sortOrder ?? -1) + 1
        ..createdAt = now
        ..updatedAt = now;
      await isar.examinationReflectionDocs.putByReflectionId(doc);
    });

    _controller.add(await listAll());
  }

  @override
  Future<void> updateItem(ExaminationReflectionItem item) async {
    final isar = await _isarProvider();

    await isar.writeTxn(() async {
      final existing = await isar.examinationReflectionDocs.getByReflectionId(
        item.id,
      );
      if (existing == null) return;

      existing.sectionTitle = item.sectionTitle;
      existing.text = item.text;
      existing.sortOrder = item.sortOrder;
      existing.createdAt = item.createdAt.toUtc();
      existing.updatedAt = DateTime.now().toUtc();
      await isar.examinationReflectionDocs.putByReflectionId(existing);
    });

    _controller.add(await listAll());
  }

  @override
  Future<void> deleteItem(String id) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      await isar.examinationReflectionDocs.deleteByReflectionId(id);
    });

    _controller.add(await listAll());
  }

  ExaminationReflectionItem _toEntity(ExaminationReflectionDoc doc) {
    return ExaminationReflectionItem(
      id: doc.reflectionId,
      sectionTitle: doc.sectionTitle,
      text: doc.text,
      sortOrder: doc.sortOrder,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
    );
  }
}
