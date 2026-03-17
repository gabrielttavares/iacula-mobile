import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/profile/presentation/profile_screen.dart';
void main() {
  testWidgets('profile renders sections when logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AuthUser(id: '1', email: 'test@example.com', displayName: 'Test User'),
            ),
          ),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Dados da conta'), findsOneWidget);
    expect(find.text('Segurança'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  });

  testWidgets('profile shows empty state when not logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sincronização entre dispositivos'), findsOneWidget);
    expect(find.text('Dados da conta'), findsNothing);
  });
}
