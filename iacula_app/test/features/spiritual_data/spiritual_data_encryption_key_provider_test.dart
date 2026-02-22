import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';

final class _InMemorySecureKvStore implements SecureKvStore {
  final Map<String, String> _values = <String, String>{};
  int writes = 0;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    writes += 1;
    _values[key] = value;
  }
}

void main() {
  test('creates and persists encryption key on first access, then reuses it', () async {
    final store = _InMemorySecureKvStore();
    final provider = SpiritualDataEncryptionKeyProvider(store: store);

    final first = await provider.getOrCreate();
    final second = await provider.getOrCreate();

    expect(first.length, 32);
    expect(second, first);
    expect(store.writes, 1);
  });
}
