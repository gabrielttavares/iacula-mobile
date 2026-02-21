import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, 'iacula.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            interval_minutes INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            autostart INTEGER NOT NULL,
            language TEXT NOT NULL,
            liturgy_sound_enabled INTEGER NOT NULL,
            liturgy_sound_volume REAL NOT NULL,
            laudes_enabled INTEGER NOT NULL,
            vespers_enabled INTEGER NOT NULL,
            compline_enabled INTEGER NOT NULL,
            ora_media_enabled INTEGER NOT NULL,
            laudes_time TEXT NOT NULL,
            vespers_time TEXT NOT NULL,
            compline_time TEXT NOT NULL,
            ora_media_time TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE quote_indices (
            day_of_week INTEGER PRIMARY KEY,
            quote_index INTEGER NOT NULL,
            image_index INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE quote_meta (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            last_day INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}
