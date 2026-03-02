import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'challenge_progress_doc.dart';
import 'favorite_item_doc.dart';
import 'journal_entry_doc.dart';
import 'liturgical_day_doc.dart';
import 'media_asset_doc.dart';
import 'prayer_activity_doc.dart';
import 'premium_status_doc.dart';

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
      [MediaAssetDocSchema, LiturgicalDayDocSchema, PremiumStatusDocSchema, FavoriteItemDocSchema, PrayerActivityDocSchema, ChallengeProgressDocSchema, JournalEntryDocSchema],
      directory: isarDirectory,
      name: 'iacula_isar',
    );
    return _isar!;
  }
}
