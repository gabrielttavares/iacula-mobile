import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_feature.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/presentation/premium_gate.dart';

void main() {
  setUp(() => PremiumGate.debugPremiumBypass = false);
  addTearDown(() => PremiumGate.debugPremiumBypass = kDebugMode);

  testWidgets('shows locked fallback when user is free', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(PremiumStatus.free);
          }),
        ],
        child: const MaterialApp(
          home: PremiumGate(
            feature: PremiumFeature.meditation,
            lockedFallback: Text('locked'),
            child: Text('unlocked'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('locked'), findsOneWidget);
    expect(find.text('unlocked'), findsNothing);
  });

  testWidgets('shows child when user is premium', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
        ],
        child: const MaterialApp(
          home: PremiumGate(
            feature: PremiumFeature.planOfLife,
            lockedFallback: Text('locked'),
            child: Text('unlocked'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('unlocked'), findsOneWidget);
    expect(find.text('locked'), findsNothing);
  });
}
