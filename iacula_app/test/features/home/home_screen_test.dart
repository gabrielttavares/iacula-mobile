import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
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

final class _FakeLastDeliveredCardRepository implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this.value);

  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

void main() {
  testWidgets('home card renders last delivered quote and feast label', (tester) async {
    final settingsRepo = _FakeSettingsRepository(
      Settings.defaults.copyWith(language: 'pt-br', intervalMinutes: 20),
    );
    final lastCardRepo = _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: 'Sede santos.',
        theme: 'Santidade',
        season: 'ordinary',
        deliveredAt: DateTime(2026, 2, 21, 10, 20),
        feast: 'all-saints',
        feastName: 'Todos os Santos',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          lastDeliveredCardRepositoryProvider.overrideWithValue(lastCardRepo),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ultima jaculatoria'), findsOneWidget);
    expect(find.text('Sede santos.'), findsOneWidget);
    expect(find.text('Todos os Santos'), findsOneWidget);
  });

  testWidgets('home card falls back to season label when feast name is absent', (tester) async {
    final settingsRepo = _FakeSettingsRepository(Settings.defaults);
    final lastCardRepo = _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: 'Permanecei em mim.',
        theme: 'Conversao',
        season: 'lent',
        deliveredAt: DateTime(2026, 2, 21, 11, 0),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          lastDeliveredCardRepositoryProvider.overrideWithValue(lastCardRepo),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Permanecei em mim.'), findsOneWidget);
    expect(find.text('tempo da quaresma'), findsOneWidget);
  });
}
