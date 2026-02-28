import 'dart:async';

import 'package:iacula_app/core/storage/isar/isar_store.dart';
import 'package:iacula_app/core/storage/isar/premium_status_doc.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:isar/isar.dart';

final class IsarPremiumRepository implements PremiumRepository {
  IsarPremiumRepository({
    IsarStore? store,
    Future<Isar> Function()? isarProvider,
  }) : _isarProvider =
           isarProvider ?? (() async => (store ?? IsarStore.instance).isar);

  final Future<Isar> Function() _isarProvider;
  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  @override
  Future<PremiumStatus> getStatus() async {
    final isar = await _isarProvider();
    final doc = await isar.premiumStatusDocs.get(0);
    if (doc == null || !doc.isPremium) {
      return PremiumStatus.free;
    }

    // Require a store transaction ID for premium to be valid locally.
    // This prevents simple Isar tampering on rooted devices from
    // bypassing the premium gate without a real purchase.
    if (doc.storeTransactionId == null || doc.storeTransactionId!.isEmpty) {
      return PremiumStatus.free;
    }

    return PremiumStatus(
      isPremium: doc.isPremium,
      purchaseDate: doc.purchaseDate,
      storeTransactionId: doc.storeTransactionId,
      userId: doc.userId,
    );
  }

  @override
  Future<void> unlockPremium(PremiumStatus status) async {
    final isar = await _isarProvider();
    await isar.writeTxn(() async {
      final doc = (await isar.premiumStatusDocs.get(0)) ?? PremiumStatusDoc();
      doc.id = 0;
      doc.isPremium = status.isPremium;
      doc.purchaseDate = status.purchaseDate?.toUtc();
      doc.storeTransactionId = status.storeTransactionId;
      doc.userId = status.userId;
      doc.lastValidated = DateTime.now().toUtc();
      await isar.premiumStatusDocs.put(doc);
    });

    _statusController.add(await getStatus());
  }

  @override
  Future<bool> restorePurchases() async {
    final current = await getStatus();
    return current.isPremium;
  }

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield await getStatus();
    yield* _statusController.stream;
  }
}
