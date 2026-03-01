// lib/features/prayer_intentions/application/use_cases/list_intentions_use_case.dart

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/prayer_intention.dart';

final class ListIntentionsUseCase {
  const ListIntentionsUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<List<PrayerIntention>> call({bool includeResponded = false}) async {
    final entries = await _repository.listLocal();
    final intentions = entries.map((e) => PrayerIntention(
      id: e.id,
      title: e.title ?? '',
      description: e.body.isNotEmpty ? e.body : null,
      createdAt: e.createdAt,
      respondedAt: e.respondedAt,
    )).toList();

    if (!includeResponded) {
      intentions.removeWhere((i) => i.isResponded);
    }

    intentions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return intentions;
  }
}
