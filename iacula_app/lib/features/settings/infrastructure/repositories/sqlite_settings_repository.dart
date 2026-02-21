import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/sqlite/app_database.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class SqliteSettingsRepository implements SettingsRepository {
  SqliteSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<Settings> load() async {
    final db = await _database.database;
    final rows = await db.query('settings', where: 'id = 1', limit: 1);

    if (rows.isEmpty) {
      await save(Settings.defaults);
      return Settings.defaults;
    }

    final row = rows.first;
    return Settings(
      intervalMinutes: row['interval_minutes'] as int,
      durationSeconds: row['duration_seconds'] as int,
      autostart: (row['autostart'] as int) == 1,
      language: row['language'] as String,
      liturgyReminderSoundEnabled: (row['liturgy_sound_enabled'] as int) == 1,
      liturgyReminderSoundVolume: (row['liturgy_sound_volume'] as num).toDouble(),
      laudesEnabled: (row['laudes_enabled'] as int) == 1,
      vespersEnabled: (row['vespers_enabled'] as int) == 1,
      complineEnabled: (row['compline_enabled'] as int) == 1,
      oraMediaEnabled: (row['ora_media_enabled'] as int) == 1,
      laudesTime: row['laudes_time'] as String,
      vespersTime: row['vespers_time'] as String,
      complineTime: row['compline_time'] as String,
      oraMediaTime: row['ora_media_time'] as String,
    );
  }

  @override
  Future<void> save(Settings settings) async {
    final db = await _database.database;
    await db.insert(
      'settings',
      {
        'id': 1,
        'interval_minutes': settings.intervalMinutes,
        'duration_seconds': settings.durationSeconds,
        'autostart': settings.autostart ? 1 : 0,
        'language': settings.language,
        'liturgy_sound_enabled': settings.liturgyReminderSoundEnabled ? 1 : 0,
        'liturgy_sound_volume': settings.liturgyReminderSoundVolume,
        'laudes_enabled': settings.laudesEnabled ? 1 : 0,
        'vespers_enabled': settings.vespersEnabled ? 1 : 0,
        'compline_enabled': settings.complineEnabled ? 1 : 0,
        'ora_media_enabled': settings.oraMediaEnabled ? 1 : 0,
        'laudes_time': settings.laudesTime,
        'vespers_time': settings.vespersTime,
        'compline_time': settings.complineTime,
        'ora_media_time': settings.oraMediaTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

