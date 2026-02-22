import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureKvStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

final class FlutterSecureKvStore implements SecureKvStore {
  FlutterSecureKvStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}

abstract interface class EncryptionKeyProvider {
  Future<List<int>> getOrCreate();
}

final class SpiritualDataEncryptionKeyProvider implements EncryptionKeyProvider {
  SpiritualDataEncryptionKeyProvider({
    required SecureKvStore store,
    this.storageKey = 'spiritual_data_isar_key',
  }) : _store = store;

  final SecureKvStore _store;
  final String storageKey;

  @override
  Future<List<int>> getOrCreate() async {
    final existing = await _store.read(storageKey);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }

    final bytes = _generateBytes();
    await _store.write(storageKey, base64Encode(bytes));
    return bytes;
  }

  List<int> _generateBytes() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }
}
