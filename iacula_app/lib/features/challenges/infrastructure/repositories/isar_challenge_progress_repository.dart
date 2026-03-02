import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../../core/storage/isar/challenge_progress_doc.dart';
import '../../../../core/storage/isar/isar_store.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenge_progress_repository.dart';

final class IsarChallengeProgressRepository
    implements ChallengeProgressRepository {
  IsarChallengeProgressRepository({required this.store});

  final IsarStore store;

  @override
  Future<ChallengeProgress?> getProgress(String challengeId) async {
    final isar = await store.isar;
    final doc = await isar.challengeProgressDocs
        .where()
        .challengeIdEqualTo(challengeId)
        .findFirst();
    return doc != null ? _toProgress(doc) : null;
  }

  @override
  Future<void> saveProgress(ChallengeProgress progress) async {
    final isar = await store.isar;
    final doc = ChallengeProgressDoc()
      ..challengeId = progress.challengeId
      ..startDate = progress.startDate
      ..completedDaysJson = jsonEncode(progress.completedDays)
      ..isCompleted = progress.isCompleted
      ..completedAt = progress.completedAt;

    await isar.writeTxn(() => isar.challengeProgressDocs.put(doc));
  }

  @override
  Future<List<ChallengeProgress>> listActive() async {
    final isar = await store.isar;
    final docs = await isar.challengeProgressDocs
        .where()
        .filter()
        .isCompletedEqualTo(false)
        .findAll();
    return docs.map(_toProgress).toList();
  }

  @override
  Future<void> deleteProgress(String challengeId) async {
    final isar = await store.isar;
    await isar.writeTxn(() async {
      await isar.challengeProgressDocs
          .where()
          .challengeIdEqualTo(challengeId)
          .deleteAll();
    });
  }

  ChallengeProgress _toProgress(ChallengeProgressDoc doc) {
    final days = (jsonDecode(doc.completedDaysJson) as List)
        .map((e) => e as int)
        .toList();
    return ChallengeProgress(
      challengeId: doc.challengeId,
      startDate: doc.startDate,
      completedDays: days,
      isCompleted: doc.isCompleted,
      completedAt: doc.completedAt,
    );
  }
}
