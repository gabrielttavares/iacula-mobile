import '../../../../core/storage/isar/isar_store.dart';
import '../../../../core/storage/isar/liturgical_day_doc.dart';
import '../../domain/liturgical_season.dart';
import '../../domain/repositories/liturgical_season_cache_repository.dart';

final class IsarLiturgicalSeasonCacheRepository implements LiturgicalSeasonCacheRepository {
  IsarLiturgicalSeasonCacheRepository(this._store);

  final IsarStore _store;

  @override
  Future<LiturgicalSeason?> getByDateKey(String dateKey) async {
    final isar = await _store.isar;
    final doc = await isar.liturgicalDayDocs.getByDateKey(dateKey);
    if (doc == null) return null;
    return _parseSeason(doc.season);
  }

  @override
  Future<void> put(String dateKey, LiturgicalSeason season) async {
    final isar = await _store.isar;
    await isar.writeTxn(() async {
      final doc = LiturgicalDayDoc()
        ..dateKey = dateKey
        ..season = season.name;
      await isar.liturgicalDayDocs.putByDateKey(doc);
    });
  }

  LiturgicalSeason _parseSeason(String value) {
    return LiturgicalSeason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LiturgicalSeason.ordinary,
    );
  }
}
