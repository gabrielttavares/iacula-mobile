import '../entities/premium_status.dart';

abstract interface class PremiumRepository {
  Future<PremiumStatus> getStatus();
  Future<void> unlockPremium(PremiumStatus status);
  Future<bool> restorePurchases();
  Stream<PremiumStatus> watchStatus();
}
