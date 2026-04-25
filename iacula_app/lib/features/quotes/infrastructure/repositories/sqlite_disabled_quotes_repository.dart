import '../../../../core/storage/sqlite/app_database.dart';
import '../../domain/repositories/disabled_quotes_repository.dart';

final class SqliteDisabledQuotesRepository implements DisabledQuotesRepository {
  SqliteDisabledQuotesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<Set<int>> loadDisabledIndices({
    required int dayOfWeek,
    required String season,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'disabled_default_quotes',
      columns: ['quote_index'],
      where: 'day_of_week = ? AND season = ?',
      whereArgs: [dayOfWeek, season],
    );
    return rows.map((r) => r['quote_index'] as int).toSet();
  }

  @override
  Future<Map<int, Set<int>>> loadAllDisabled({required String season}) async {
    final db = await _database.database;
    final rows = await db.query(
      'disabled_default_quotes',
      where: 'season = ?',
      whereArgs: [season],
    );
    final result = <int, Set<int>>{};
    for (final row in rows) {
      final day = row['day_of_week'] as int;
      final index = row['quote_index'] as int;
      (result[day] ??= <int>{}).add(index);
    }
    return result;
  }

  @override
  Future<void> toggle({
    required int dayOfWeek,
    required int quoteIndex,
    required String season,
  }) async {
    final db = await _database.database;
    final existing = await db.query(
      'disabled_default_quotes',
      where: 'day_of_week = ? AND quote_index = ? AND season = ?',
      whereArgs: [dayOfWeek, quoteIndex, season],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      await db.delete(
        'disabled_default_quotes',
        where: 'day_of_week = ? AND quote_index = ? AND season = ?',
        whereArgs: [dayOfWeek, quoteIndex, season],
      );
    } else {
      await db.insert('disabled_default_quotes', {
        'day_of_week': dayOfWeek,
        'quote_index': quoteIndex,
        'season': season,
      });
    }
  }
}
