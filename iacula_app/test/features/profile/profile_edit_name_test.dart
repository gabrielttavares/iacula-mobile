import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/profile/presentation/profile_screen.dart';

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> currentUser() async => _user;

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(_user);

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithMicrosoft() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('edit button opens dialog when user is authenticated', (
    tester,
  ) async {
    const user = AuthUser(
      id: '1',
      email: 'test@test.com',
      displayName: 'Maria',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap the first "Editar" button (Conta section)
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
  });

  testWidgets('edit button opens local name editor when unauthenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository(null)),
        ],
        child: const CupertinoApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();
    expect(find.text('Seu nome'), findsOneWidget);
  });
}
