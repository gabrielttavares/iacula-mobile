import '../domain/entities/premium_status.dart';
import '../domain/repositories/premium_repository.dart';

final class AlwaysUnlockedPremiumRepository implements PremiumRepository {
  static final PremiumStatus _freeAccessStatus = PremiumStatus(
    isPremium: true,
    storeTransactionId: 'free-access',
  );

  @override
  Future<PremiumStatus> getStatus() async => _freeAccessStatus;

  @override
  Future<void> unlockPremium(PremiumStatus status) async {
    // TODO(gabrielttav): restore persisted premium state when paid access returns.
  }

  @override
  Future<bool> restorePurchases() async => true;

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield _freeAccessStatus;
  }
}
