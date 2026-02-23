import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class PurchaseService {
  Future<bool> purchasePremium(String productId);
  Future<bool> restorePurchases();
  Stream<PurchaseStatus> get purchaseStream;
}

abstract interface class InAppPurchaseStore {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam});
  Future<void> restorePurchases({String? applicationUserName});
}

final class InAppPurchaseStoreAdapter implements InAppPurchaseStore {
  InAppPurchaseStoreAdapter([InAppPurchase? inAppPurchase])
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return _inAppPurchase.queryProductDetails(identifiers);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) {
    return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) {
    return _inAppPurchase.restorePurchases(
      applicationUserName: applicationUserName,
    );
  }
}

final class StorePurchaseService implements PurchaseService {
  StorePurchaseService({InAppPurchaseStore? store})
    : _store = store ?? InAppPurchaseStoreAdapter();

  final InAppPurchaseStore _store;

  @override
  Stream<PurchaseStatus> get purchaseStream {
    return _store.purchaseStream.expand(
      (purchases) => purchases.map((purchase) => purchase.status),
    );
  }

  @override
  Future<bool> purchasePremium(String productId) async {
    final response = await _store.queryProductDetails(<String>{productId});
    if (response.error != null) {
      return false;
    }

    ProductDetails? details;
    for (final candidate in response.productDetails) {
      if (candidate.id == productId) {
        details = candidate;
        break;
      }
    }

    if (details == null) {
      return false;
    }

    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      await _store.restorePurchases();
      return true;
    } catch (_) {
      return false;
    }
  }
}
