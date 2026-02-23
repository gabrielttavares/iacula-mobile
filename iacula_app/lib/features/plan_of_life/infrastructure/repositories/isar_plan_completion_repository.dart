import 'package:isar/isar.dart';

import '../../../../core/storage/isar/plan_completion_doc.dart';
import '../../../spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../domain/entities/daily_completion.dart';
import '../../domain/repositories/plan_completion_repository.dart';

class IsarPlanCompletionRepository implements PlanCompletionRepository {
  IsarPlanCompletionRepository(this._store);

  final SpiritualDataIsarStore _store;

  @override
  Future<List<DailyCompletion>> getCompletionsForDate(String date) async {
    final isar = await _store.isar;
    final docs = await isar.planCompletionDocs.filter().dateEqualTo(date).findAll();
    return docs
        .map(
          (doc) => DailyCompletion(
            itemId: doc.itemId,
            date: doc.date,
            completedAt: doc.completedAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletion(DailyCompletion completion) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final existing = await isar.planCompletionDocs.getByCompletionId(completion.id);
      final doc = existing ?? PlanCompletionDoc()
        ..completionId = completion.id;
      doc.itemId = completion.itemId;
      doc.date = completion.date;
      doc.completedAt = completion.completedAt;
      await isar.planCompletionDocs.putByCompletionId(doc);
    });
  }

  @override
  Future<void> deleteCompletion(String itemId, String date) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final completionId = '${itemId}_$date';
      await isar.planCompletionDocs.deleteByCompletionId(completionId);
    });
  }
}
