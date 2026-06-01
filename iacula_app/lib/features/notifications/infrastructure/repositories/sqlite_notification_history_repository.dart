import '../../../../core/storage/sqlite/app_database.dart';
import '../../domain/entities/notification_history_entry.dart';
import '../../domain/repositories/notification_history_repository.dart';

final class SqliteNotificationHistoryRepository
    implements NotificationHistoryRepository {
  SqliteNotificationHistoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> add(NotificationHistoryEntry entry) async {
    final db = await _database.database;
    final existing = await db.query(
      'notification_history_entries',
      columns: ['id'],
      where: 'quote_text = ? AND delivered_at = ?',
      whereArgs: [entry.quoteText, entry.deliveredAt.toIso8601String()],
      limit: 1,
    );
    if (existing.isNotEmpty) return;
    await db.insert('notification_history_entries', {
      'quote_text': entry.quoteText,
      'theme': entry.theme,
      'season': entry.season,
      'image_path': entry.imagePath,
      'feast_name': entry.feastName,
      'delivered_at': entry.deliveredAt.toIso8601String(),
      'source': entry.source,
      'reference_label': entry.referenceLabel,
    });
  }

  @override
  Future<void> clearFrom(DateTime instant) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    final db = await _database.database;
    await db.delete(
      'notification_history_entries',
      where: 'delivered_at > ? AND delivered_at < ?',
      whereArgs: [instant.toIso8601String(), end.toIso8601String()],
    );
  }

  @override
  Future<void> clearFromExcept(
    DateTime instant,
    Set<String> keepTimestamps,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    final db = await _database.database;
    if (keepTimestamps.isEmpty) {
      await db.delete(
        'notification_history_entries',
        where: 'delivered_at > ? AND delivered_at < ?',
        whereArgs: [instant.toIso8601String(), end.toIso8601String()],
      );
      return;
    }
    final placeholders = List.filled(keepTimestamps.length, '?').join(', ');
    await db.delete(
      'notification_history_entries',
      where:
          'delivered_at > ? AND delivered_at < ? AND delivered_at NOT IN ($placeholders)',
      whereArgs: [
        instant.toIso8601String(),
        end.toIso8601String(),
        ...keepTimestamps,
      ],
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listFromUntilEndOfDay(
    DateTime instant,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    final db = await _database.database;
    // Inclusive lower bound (`>=`) on purpose: a rebuild can run at exactly a
    // slot's fire instant, and the row at that instant is the slot's cached
    // assignment to reuse — a strict `>` would hide it, so the slot gets
    // redrawn and the app shows a different quote than the OS already scheduled.
    // This intentionally differs from clearFrom/clearFromExcept below, which use
    // strict `>` so they can never delete the just-fired row. Do not align them.
    final rows = await db.query(
      'notification_history_entries',
      where: 'delivered_at >= ? AND delivered_at < ?',
      whereArgs: [instant.toIso8601String(), end.toIso8601String()],
      orderBy: 'delivered_at ASC',
    );
    return rows
        .map(
          (row) => NotificationHistoryEntry(
            quoteText: row['quote_text'] as String,
            theme: row['theme'] as String,
            season: row['season'] as String,
            deliveredAt:
                DateTime.tryParse(row['delivered_at'] as String? ?? '') ??
                instant,
            imagePath: row['image_path'] as String?,
            feastName: row['feast_name'] as String?,
            source: row['source'] as String?,
            referenceLabel: row['reference_label'] as String?,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final db = await _database.database;
    final rows = await db.query(
      'notification_history_entries',
      where: 'delivered_at >= ? AND delivered_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'delivered_at DESC',
    );

    return rows
        .map(
          (row) => NotificationHistoryEntry(
            quoteText: row['quote_text'] as String,
            theme: row['theme'] as String,
            season: row['season'] as String,
            deliveredAt:
                DateTime.tryParse(row['delivered_at'] as String? ?? '') ??
                start,
            imagePath: row['image_path'] as String?,
            feastName: row['feast_name'] as String?,
            source: row['source'] as String?,
            referenceLabel: row['reference_label'] as String?,
          ),
        )
        .toList(growable: false);
  }
}
