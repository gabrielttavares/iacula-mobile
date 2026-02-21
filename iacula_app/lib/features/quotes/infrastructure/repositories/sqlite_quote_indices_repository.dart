import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/sqlite/app_database.dart';
import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_indices_repository.dart';

final class SqliteQuoteIndicesRepository implements QuoteIndicesRepository {
  SqliteQuoteIndicesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async {
    final db = await _database.database;

    final meta = await db.query('quote_meta', where: 'id = 1', limit: 1);
    if (meta.isEmpty) {
      await db.insert('quote_meta', {'id': 1, 'last_day': dayOfWeek}, conflictAlgorithm: ConflictAlgorithm.replace);
      return QuoteIndices.empty(dayOfWeek);
    }

    final lastDay = meta.first['last_day'] as int;
    if (lastDay != dayOfWeek) {
      await db.delete('quote_indices');
      await db.insert('quote_meta', {'id': 1, 'last_day': dayOfWeek}, conflictAlgorithm: ConflictAlgorithm.replace);
      return QuoteIndices.empty(dayOfWeek);
    }

    final rows = await db.query('quote_indices');
    final quoteIndices = <int, int>{};
    final imageIndices = <int, int>{};

    for (final row in rows) {
      final day = row['day_of_week'] as int;
      quoteIndices[day] = row['quote_index'] as int;
      imageIndices[day] = row['image_index'] as int;
    }

    return QuoteIndices(
      quoteIndices: quoteIndices,
      imageIndices: imageIndices,
      lastDay: lastDay,
    );
  }

  @override
  Future<void> save(QuoteIndices indices) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('quote_indices');

      final days = <int>{}
        ..addAll(indices.quoteIndices.keys)
        ..addAll(indices.imageIndices.keys);

      for (final day in days) {
        await txn.insert('quote_indices', {
          'day_of_week': day,
          'quote_index': indices.quoteIndices[day] ?? 0,
          'image_index': indices.imageIndices[day] ?? 0,
        });
      }

      await txn.insert('quote_meta', {'id': 1, 'last_day': indices.lastDay}, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}

