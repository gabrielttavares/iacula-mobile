import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_feature.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';

void main() {
  test('premium features include expected locked sections', () {
    expect(
      PremiumFeature.values,
      containsAll([
        PremiumFeature.streakDashboard,
        PremiumFeature.leituras,
        PremiumFeature.journal,
      ]),
    );
  });

  test('free status constant is non-premium and empty metadata', () {
    expect(PremiumStatus.free.isPremium, isFalse);
    expect(PremiumStatus.free.purchaseDate, isNull);
    expect(PremiumStatus.free.storeTransactionId, isNull);
    expect(PremiumStatus.free.userId, isNull);
  });
}
