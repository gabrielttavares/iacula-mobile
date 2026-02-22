import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/isar/examination_entry_doc.dart';
import '../../../../core/storage/isar/plan_of_life_entry_doc.dart';
import '../../../../core/storage/isar/prayer_intention_entry_doc.dart';
import '../../../../core/storage/isar/sync_state_doc.dart';
import 'spiritual_data_encryption_key_provider.dart';

typedef SpiritualIsarOpenFn = Future<Isar> Function({
  required List<CollectionSchema<dynamic>> schemas,
  required String directory,
  required String name,
  required List<int> encryptionKey,
});

final class SpiritualDataIsarStore {
  SpiritualDataIsarStore({
    required EncryptionKeyProvider keyProvider,
    Future<String> Function()? directoryProvider,
    SpiritualIsarOpenFn? openIsar,
  })  : _keyProvider = keyProvider,
        _directoryProvider = directoryProvider ?? _defaultDirectoryProvider,
        _openIsar = openIsar ?? _defaultOpenIsar;

  final EncryptionKeyProvider _keyProvider;
  final Future<String> Function() _directoryProvider;
  final SpiritualIsarOpenFn _openIsar;

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final encryptionKey = await _keyProvider.getOrCreate();
    final directory = await _directoryProvider();
    await Directory(directory).create(recursive: true);

    _isar = await _openIsar(
      schemas: <CollectionSchema<dynamic>>[
        PlanOfLifeEntryDocSchema,
        ExaminationEntryDocSchema,
        PrayerIntentionEntryDocSchema,
        SyncStateDocSchema,
      ],
      directory: directory,
      name: 'iacula_spiritual_isar',
      encryptionKey: encryptionKey,
    );

    return _isar!;
  }

  static Future<String> _defaultDirectoryProvider() async {
    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, 'isar_spiritual');
  }

  static Future<Isar> _defaultOpenIsar({
    required List<CollectionSchema<dynamic>> schemas,
    required String directory,
    required String name,
    required List<int> encryptionKey,
  }) {
    return Isar.open(
      schemas,
      directory: directory,
      name: name,
    );
  }
}
