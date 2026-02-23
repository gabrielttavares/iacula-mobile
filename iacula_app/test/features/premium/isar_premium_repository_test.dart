import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/storage/isar/premium_status_doc.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/infrastructure/isar_premium_repository.dart';
import 'package:isar/isar.dart';

void main() {
  test(
    'persists and watches premium status in isar repository contract',
    () async {
      final isar = _FakeIsar();
      final repository = IsarPremiumRepository(isarProvider: () async => isar);
      final statuses = <PremiumStatus>[];
      final sub = repository.watchStatus().listen(statuses.add);

      await Future<void>.delayed(Duration.zero);
      expect(statuses.first, PremiumStatus.free);

      await repository.unlockPremium(
        PremiumStatus(
          isPremium: true,
          purchaseDate: DateTime.utc(2026, 2, 22),
          storeTransactionId: 'tx-900',
          userId: 'user-9',
        ),
      );

      final persisted = await repository.getStatus();
      expect(persisted.isPremium, isTrue);
      expect(persisted.userId, 'user-9');
      expect(await repository.restorePurchases(), isTrue);
      expect(statuses.any((status) => status.isPremium), isTrue);

      await sub.cancel();
    },
  );
}

final class _FakeIsar implements Isar {
  final _collection = _FakePremiumStatusCollection();

  @override
  IsarCollection<OBJ> collection<OBJ>() {
    return _collection as IsarCollection<OBJ>;
  }

  @override
  Future<T> writeTxn<T>(
    Future<T> Function() callback, {
    bool silent = false,
  }) async {
    return callback();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakePremiumStatusCollection
    implements IsarCollection<PremiumStatusDoc> {
  PremiumStatusDoc? _doc;

  @override
  Future<PremiumStatusDoc?> get(Id id) async => _doc;

  @override
  Future<Id> put(PremiumStatusDoc object) async {
    _doc = object;
    return object.id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
