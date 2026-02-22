import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/repositories/isar_spiritual_entry_repositories.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

final class _FakeKeyProvider implements EncryptionKeyProvider {
  @override
  Future<List<int>> getOrCreate() async => List<int>.filled(32, 3);
}

void main() {
  test('plan of life local repository supports save, dirty tracking and tombstone delete', () async {
    if (!Platform.isMacOS) {
      return;
    }

    await Isar.initializeIsarCore(
      libraries: {
        Abi.current(): p.join(Directory.current.path, 'third_party/isar_flutter_libs/macos/libisar.dylib'),
      },
    );

    final temp = await Directory.systemTemp.createTemp('iacula-plan-test');
    final store = SpiritualDataIsarStore(
      keyProvider: _FakeKeyProvider(),
      directoryProvider: () async => temp.path,
    );
    final repo = IsarPlanOfLifeSpiritualEntryRepository(store);

    final entry = SpiritualEntry(
      id: 'id-1',
      module: SpiritualModule.planOfLife,
      title: 'Rule',
      body: 'Pray morning and evening',
      scheduleJson: '{"days":[1,2,3]}',
      createdAt: DateTime.utc(2026, 2, 22, 12),
      updatedAt: DateTime.utc(2026, 2, 22, 12),
    );

    await repo.saveLocal(entry);
    expect((await repo.listDirty()).length, 1);

    await repo.markClean('id-1', syncedAt: DateTime.utc(2026, 2, 22, 12, 30));
    expect(await repo.listDirty(), isEmpty);

    await repo.markDeleted('id-1', deletedAt: DateTime.utc(2026, 2, 22, 13));

    final visible = await repo.listLocal();
    final all = await repo.listLocal(includeDeleted: true);

    expect(visible, isEmpty);
    expect(all.length, 1);
    expect(all.first.deletedAt, isNotNull);

    final isar = await store.isar;
    await isar.close(deleteFromDisk: true);
    await temp.delete(recursive: true);
  });
}
