import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'favorite_item_doc.dart';
import 'journal_entry_doc.dart';
import 'liturgical_day_doc.dart';
import 'media_asset_doc.dart';
import 'prayer_activity_doc.dart';
import 'premium_status_doc.dart';
import 'reading_bookmark_doc.dart';
import 'reading_highlight_doc.dart';
import 'reading_progress_doc.dart';

final class IsarStore {
  IsarStore._();

  static final IsarStore instance = IsarStore._();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final databasesPath = await getDatabasesPath();
    final isarDirectory = p.join(databasesPath, 'isar');
    await Directory(isarDirectory).create(recursive: true);
    _isar = await Isar.open(
      [
        MediaAssetDocSchema,
        LiturgicalDayDocSchema,
        PremiumStatusDocSchema,
        FavoriteItemDocSchema,
        PrayerActivityDocSchema,
        JournalEntryDocSchema,
        ReadingHighlightDocSchema,
        ReadingBookmarkDocSchema,
        ReadingProgressDocSchema,
      ],
      directory: isarDirectory,
      name: 'iacula_isar',
    );
    return _isar!;
  }
}
