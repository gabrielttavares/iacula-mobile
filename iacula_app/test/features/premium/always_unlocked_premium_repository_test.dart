import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/infrastructure/always_unlocked_premium_repository.dart';

void main() {
  test('getStatus returns unlocked premium status', () async {
    final repository = AlwaysUnlockedPremiumRepository();

    final status = await repository.getStatus();

    expect(status.isPremium, isTrue);
    expect(status.storeTransactionId, 'free-access');
  });

  test('watchStatus emits unlocked premium status', () async {
    final repository = AlwaysUnlockedPremiumRepository();

    await expectLater(
      repository.watchStatus(),
      emits(
        isA<PremiumStatus>().having(
          (status) => status.isPremium,
          'isPremium',
          isTrue,
        ),
      ),
    );
  });

  test('restorePurchases stays truthy for free-access runtime', () async {
    final repository = AlwaysUnlockedPremiumRepository();

    final restored = await repository.restorePurchases();

    expect(restored, isTrue);
  });
}
