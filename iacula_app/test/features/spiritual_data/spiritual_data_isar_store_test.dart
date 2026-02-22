import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import 'package:isar/isar.dart';

final class _FakeKeyProvider implements EncryptionKeyProvider {
  @override
  Future<List<int>> getOrCreate() async => List<int>.filled(32, 7);
}

void main() {
  test('passes encryption key to isar opener and caches instance', () async {
    List<int>? seenKey;
    var openCalls = 0;
    final fake = _FakeIsar();

    Future<Isar> open({
      required List<CollectionSchema<dynamic>> schemas,
      required String directory,
      required String name,
      required List<int> encryptionKey,
    }) async {
      openCalls += 1;
      seenKey = encryptionKey;
      return fake;
    }

    final store = SpiritualDataIsarStore(
      keyProvider: _FakeKeyProvider(),
      directoryProvider: () async => '/tmp/iacula-tests',
      openIsar: open,
    );

    final first = await store.isar;
    final second = await store.isar;

    expect(first, same(fake));
    expect(second, same(fake));
    expect(openCalls, 1);
    expect(seenKey, isNotNull);
    expect(seenKey!.length, 32);
    expect(seenKey!.first, 7);
  });
}

final class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
