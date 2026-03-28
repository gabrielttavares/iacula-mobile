import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart' show AuthUser, Gender;
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

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this.value);

  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

Widget _buildApp({List<Override> extraOverrides = const []}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        _FakeSettingsRepository(Settings.defaults),
      ),
      lastDeliveredCardRepositoryProvider.overrideWithValue(
        _FakeLastDeliveredCardRepository(
          LastDeliveredCard(
            quoteText: 'Permanecei em mim.',
            theme: 'Conversao',
            season: 'lent',
            deliveredAt: DateTime(2026, 2, 21, 11, 0),
          ),
        ),
      ),
      ...extraOverrides,
    ],
    child: const CupertinoApp(home: HomeScreen()),
  );
}

void main() {
  String _largeTitleText(WidgetTester tester) {
    final nav = tester.widget<CupertinoSliverNavigationBar>(
      find.byType(CupertinoSliverNavigationBar),
    );
    final text = nav.largeTitle! as Text;
    return text.data ?? '';
  }

  testWidgets('shows neutral Olá when unauthenticated without local name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final greeting = _largeTitleText(tester);
    expect(greeting, 'Olá!');
    expect(greeting, isNot(contains('Pedro')));
  });

  testWidgets('shows Olá with local name when unauthenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(
              Settings.defaults.copyWith(displayName: 'Pedro'),
            ),
          ),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(
              LastDeliveredCard(
                quoteText: 'Permanecei em mim.',
                theme: 'Conversao',
                season: 'lent',
                deliveredAt: DateTime(2026, 2, 21, 11, 0),
              ),
            ),
          ),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_largeTitleText(tester), 'Olá, Pedro!');
  });

  testWidgets('uses local name while auth stream has not emitted yet', (
    tester,
  ) async {
    final controller = StreamController<AuthUser?>();
    addTearDown(() async => controller.close());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(
              Settings.defaults.copyWith(displayName: 'Local'),
            ),
          ),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(
              LastDeliveredCard(
                quoteText: 'Permanecei em mim.',
                theme: 'Conversao',
                season: 'lent',
                deliveredAt: DateTime(2026, 2, 21, 11, 0),
              ),
            ),
          ),
          authStateProvider.overrideWith((ref) => controller.stream),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_largeTitleText(tester), 'Olá, Local!');
  });

  testWidgets('shows Olá with account name when authenticated', (tester) async {
    const user = AuthUser(
      id: '1',
      email: 'test@test.com',
      displayName: 'Maria',
      gender: Gender.female,
    );
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_largeTitleText(tester), 'Olá, Maria!');
  });

  testWidgets('shows Olá with account name when authenticated (male)', (
    tester,
  ) async {
    const user = AuthUser(
      id: '1',
      email: 'test@test.com',
      displayName: 'Pedro',
      gender: Gender.male,
    );
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_largeTitleText(tester), 'Olá, Pedro!');
  });

  testWidgets('shows Olá! when user has no displayName and no local', (
    tester,
  ) async {
    const user = AuthUser(id: '1', email: 'test@test.com');
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_largeTitleText(tester), 'Olá!');
  });

  testWidgets('falls back to local name when auth displayName is empty', (
    tester,
  ) async {
    const user = AuthUser(
      id: '1',
      email: 'test@test.com',
      displayName: '',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(
              Settings.defaults.copyWith(displayName: 'Ana'),
            ),
          ),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(
              LastDeliveredCard(
                quoteText: 'Permanecei em mim.',
                theme: 'Conversao',
                season: 'lent',
                deliveredAt: DateTime(2026, 2, 21, 11, 0),
              ),
            ),
          ),
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_largeTitleText(tester), 'Olá, Ana!');
  });
}
