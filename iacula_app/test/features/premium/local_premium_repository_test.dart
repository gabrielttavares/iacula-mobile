import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/infrastructure/local_premium_repository.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';

final class _InMemorySecureKvStore implements SecureKvStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

void main() {
  group('LocalPremiumRepository', () {
    test('returns free status by default', () async {
      final repository = LocalPremiumRepository(
        store: _InMemorySecureKvStore(),
      );

      final status = await repository.getStatus();

      expect(status, PremiumStatus.free);
      expect(await repository.restorePurchases(), isFalse);
    });

    test('persists unlocked premium metadata', () async {
      final repository = LocalPremiumRepository(
        store: _InMemorySecureKvStore(),
      );
      final purchaseDate = DateTime.utc(2026, 2, 22, 13, 45);

      await repository.unlockPremium(
        PremiumStatus(
          isPremium: true,
          purchaseDate: purchaseDate,
          storeTransactionId: 'tx-123',
          userId: 'user-1',
        ),
      );

      final status = await repository.getStatus();

      expect(status.isPremium, isTrue);
      expect(status.purchaseDate, purchaseDate);
      expect(status.storeTransactionId, 'tx-123');
      expect(status.userId, 'user-1');
      expect(await repository.restorePurchases(), isTrue);
    });

    test(
      'watchStatus emits persisted value then updates after unlock',
      () async {
        final repository = LocalPremiumRepository(
          store: _InMemorySecureKvStore(),
        );

        final updateCompleter = Completer<PremiumStatus>();
        final firstEmission = Completer<void>();
        var firstEmissionSeen = false;

        final subscription = repository.watchStatus().listen((status) {
          if (!firstEmissionSeen) {
            firstEmissionSeen = true;
            expect(status.isPremium, isFalse);
            firstEmission.complete();
            return;
          }

          if (!updateCompleter.isCompleted) {
            updateCompleter.complete(status);
          }
        });

        await firstEmission.future.timeout(const Duration(seconds: 2));

        await repository.unlockPremium(
          PremiumStatus(
            isPremium: true,
            purchaseDate: DateTime.utc(2026, 2, 22),
            storeTransactionId: 'tx-xyz',
            userId: 'user-2',
          ),
        );

        final updated = await updateCompleter.future.timeout(
          const Duration(seconds: 2),
        );
        expect(updated.isPremium, isTrue);

        await subscription.cancel();
      },
    );
  });
}
