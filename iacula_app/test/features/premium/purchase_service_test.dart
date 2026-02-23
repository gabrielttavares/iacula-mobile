import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final class _FakeInAppPurchaseStore implements InAppPurchaseStore {
  _FakeInAppPurchaseStore({
    required this.queryResponse,
    this.throwOnRestore = false,
  });

  final ProductDetailsResponse queryResponse;
  final bool throwOnRestore;
  final StreamController<List<PurchaseDetails>> _purchases =
      StreamController<List<PurchaseDetails>>.broadcast();

  PurchaseParam? lastPurchaseParam;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.stream;

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastPurchaseParam = purchaseParam;
    return true;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return queryResponse;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    if (throwOnRestore) {
      throw StateError('restore error');
    }
  }

  void emit(PurchaseStatus status) {
    _purchases.add(<PurchaseDetails>[
      PurchaseDetails(
        productID: 'premium_lifetime',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local',
          serverVerificationData: 'server',
          source: 'test',
        ),
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
        status: status,
      ),
    ]);
  }

  Future<void> dispose() async {
    await _purchases.close();
  }
}

void main() {
  test('purchasePremium buys known non-consumable product', () async {
    final store = _FakeInAppPurchaseStore(
      queryResponse: ProductDetailsResponse(
        productDetails: <ProductDetails>[
          ProductDetails(
            id: 'premium_lifetime',
            title: 'Premium',
            description: 'Lifetime premium',
            price: 'R\$60.00',
            rawPrice: 60,
            currencyCode: 'BRL',
          ),
        ],
        notFoundIDs: const <String>[],
      ),
    );
    final service = StorePurchaseService(store: store);

    final success = await service.purchasePremium('premium_lifetime');

    expect(success, isTrue);
    expect(store.lastPurchaseParam, isNotNull);
    expect(store.lastPurchaseParam!.productDetails.id, 'premium_lifetime');

    await store.dispose();
  });

  test('purchasePremium returns false when product is not found', () async {
    final store = _FakeInAppPurchaseStore(
      queryResponse: ProductDetailsResponse(
        productDetails: const <ProductDetails>[],
        notFoundIDs: const <String>['premium_lifetime'],
      ),
    );
    final service = StorePurchaseService(store: store);

    final success = await service.purchasePremium('premium_lifetime');

    expect(success, isFalse);

    await store.dispose();
  });

  test('purchaseStream exposes purchase status updates', () async {
    final store = _FakeInAppPurchaseStore(
      queryResponse: ProductDetailsResponse(
        productDetails: const <ProductDetails>[],
        notFoundIDs: const <String>[],
      ),
    );
    final service = StorePurchaseService(store: store);

    final statuses = <PurchaseStatus>[];
    final sub = service.purchaseStream.listen(statuses.add);

    store.emit(PurchaseStatus.purchased);
    await Future<void>.delayed(Duration.zero);

    expect(statuses, contains(PurchaseStatus.purchased));

    await sub.cancel();
    await store.dispose();
  });

  test('restorePurchases returns false when store throws', () async {
    final store = _FakeInAppPurchaseStore(
      queryResponse: ProductDetailsResponse(
        productDetails: const <ProductDetails>[],
        notFoundIDs: const <String>[],
      ),
      throwOnRestore: true,
    );
    final service = StorePurchaseService(store: store);

    final restored = await service.restorePurchases();

    expect(restored, isFalse);

    await store.dispose();
  });
}
