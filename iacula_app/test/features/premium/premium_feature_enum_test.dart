import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_feature.dart';

void main() {
  test('PremiumFeature only contains implemented features', () {
    final values = PremiumFeature.values.map((e) => e.name).toList();
    expect(values, containsAll(['streakDashboard', 'leituras', 'journal']));
    expect(values, isNot(contains('novenas')));
    expect(values, isNot(contains('settings')));
    expect(values, isNot(contains('meditation')));
    expect(values, isNot(contains('planOfLife')));
    expect(values, isNot(contains('rosary')));
  });
}
