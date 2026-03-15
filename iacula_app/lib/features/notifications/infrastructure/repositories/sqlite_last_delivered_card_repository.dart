import '../../../../core/storage/sqlite/app_database.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';

final class SqliteLastDeliveredCardRepository implements LastDeliveredCardRepository {
  SqliteLastDeliveredCardRepository(this._database);

  final AppDatabase _database;

  @override
  Future<LastDeliveredCard?> load() async {
    final db = await _database.database;
    final rows = await db.query(
      'last_delivered_card',
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return LastDeliveredCard(
      quoteText: row['quote_text'] as String,
      theme: row['theme'] as String,
      season: row['season'] as String,
      deliveredAt: DateTime.tryParse(row['delivered_at'] as String? ?? '') ?? DateTime.now(),
      imagePath: row['image_path'] as String?,
      feast: row['feast'] as String?,
      feastName: row['feast_name'] as String?,
      source: row['source'] as String?,
      referenceLabel: row['reference_label'] as String?,
    );
  }

  @override
  Future<void> save(LastDeliveredCard card) async {
    final db = await _database.database;
    await db.insert(
      'last_delivered_card',
      {
        'id': 1,
        'quote_text': card.quoteText,
        'theme': card.theme,
        'season': card.season,
        'image_path': card.imagePath,
        'feast': card.feast,
        'feast_name': card.feastName,
        'delivered_at': card.deliveredAt.toIso8601String(),
        'source': card.source,
        'reference_label': card.referenceLabel,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
