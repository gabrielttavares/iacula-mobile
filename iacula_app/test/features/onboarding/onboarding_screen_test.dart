import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.value);

  Settings value;

  @override
  Future<Settings> load() async => value;

  @override
  Future<void> save(Settings settings) async {
    value = settings;
  }
}

Widget _buildApp(_FakeSettingsRepository repo) {
  return ProviderScope(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    child: CupertinoApp(
      home: repo.value.onboardingCompleted
          ? const ShellScreen()
          : const OnboardingScreen(),
    ),
  );
}

void main() {
  testWidgets('onboarding appears in first launch and persists completion', (
    tester,
  ) async {
    final repo = _FakeSettingsRepository(Settings.defaults);

    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    Future<void> reveal(String text) async {
      final finder = find.text(text);
      for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -220));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Iacula'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle_grid_3x3_fill), findsNothing);
    expect(find.text('Volte a Deus ao longo do dia.'), findsOneWidget);
    expect(
      find.text(
        'Um caminho simples de oração, leitura e exame para recomeçar com constância.',
      ),
      findsOneWidget,
    );
    await reveal('Reze sem se perder');
    await reveal('Volte rápido ao essencial');
    await reveal('Siga um ritmo de oração');
    expect(find.text('Jaculatórias do dia'), findsNothing);
    await reveal('Quero começar agora');
    expect(find.text('Iacula • presença de Deus no cotidiano'), findsNothing);

    await tester.dragUntilVisible(
      find.text('Quero começar agora'),
      find.byType(ListView),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero começar agora'));
    await tester.pumpAndSettle();

    expect(repo.value.onboardingCompleted, isTrue);
    expect(find.byType(ShellScreen), findsOneWidget);

    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(ShellScreen), findsOneWidget);
  });
}
