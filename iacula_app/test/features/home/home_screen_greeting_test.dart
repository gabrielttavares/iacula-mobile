import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
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
  testWidgets('shows generic greeting when unauthenticated', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paz e bem!'), findsOneWidget);
    expect(find.text('Paz e bem, Pedro!'), findsNothing);
  });

  testWidgets('shows user name in greeting when authenticated', (tester) async {
    const user = AuthUser(id: '1', email: 'test@test.com', displayName: 'Maria');
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paz e bem, Maria!'), findsOneWidget);
  });

  testWidgets('shows generic greeting when user has no displayName', (tester) async {
    const user = AuthUser(id: '1', email: 'test@test.com');
    await tester.pumpWidget(
      _buildApp(
        extraOverrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paz e bem!'), findsOneWidget);
  });
}
