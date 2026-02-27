import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iacula_app/app/app.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

class _FirstLaunchSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async =>
      Settings.defaults.copyWith(onboardingCompleted: false);

  @override
  Future<void> save(Settings settings) async {}
}

void main() {
  testWidgets('renderiza onboarding no primeiro launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FirstLaunchSettingsRepository(),
          ),
        ],
        child: const IaculaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
