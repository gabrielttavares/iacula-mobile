import 'dart:async';

import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';

final class LocalPremiumRepository implements PremiumRepository {
  LocalPremiumRepository({SecureKvStore? store})
    : _store = store ?? FlutterSecureKvStore();

  static const _isPremiumKey = 'premium_is_premium';
  static const _purchaseDateKey = 'premium_purchase_date';
  static const _transactionIdKey = 'premium_transaction_id';
  static const _userIdKey = 'premium_user_id';

  final SecureKvStore _store;
  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  @override
  Future<PremiumStatus> getStatus() async {
    final isPremiumRaw = await _store.read(_isPremiumKey);
    if (isPremiumRaw != 'true') {
      return PremiumStatus.free;
    }

    final purchaseDateRaw = await _store.read(_purchaseDateKey);
    final transactionIdRaw = await _store.read(_transactionIdKey);
    final userIdRaw = await _store.read(_userIdKey);

    return PremiumStatus(
      isPremium: true,
      purchaseDate: DateTime.tryParse(purchaseDateRaw ?? ''),
      storeTransactionId: _nullableValue(transactionIdRaw),
      userId: _nullableValue(userIdRaw),
    );
  }

  @override
  Future<void> unlockPremium(PremiumStatus status) async {
    await _store.write(_isPremiumKey, status.isPremium ? 'true' : 'false');
    await _store.write(
      _purchaseDateKey,
      status.purchaseDate?.toIso8601String() ?? '',
    );
    await _store.write(_transactionIdKey, status.storeTransactionId ?? '');
    await _store.write(_userIdKey, status.userId ?? '');

    _statusController.add(await getStatus());
  }

  @override
  Future<bool> restorePurchases() async {
    final status = await getStatus();
    return status.isPremium;
  }

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield await getStatus();
    yield* _statusController.stream;
  }

  static String? _nullableValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}
