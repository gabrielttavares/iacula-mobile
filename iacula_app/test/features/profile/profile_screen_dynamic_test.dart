import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('shows "Sem conta" when unauthenticated', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sem conta'), findsOneWidget);
    expect(find.text('Pedro Gabriel'), findsNothing);
  });

  testWidgets('shows user data when authenticated', (tester) async {
    const user =
        AuthUser(id: '1', email: 'maria@test.com', displayName: 'Maria');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('maria@test.com'), findsOneWidget);
  });

  testWidgets('avatar initials reflect real user name', (tester) async {
    const user =
        AuthUser(id: '1', email: 'a@b.com', displayName: 'Ana Beatriz');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AB'), findsOneWidget);
    expect(find.text('PG'), findsNothing);
  });
}
