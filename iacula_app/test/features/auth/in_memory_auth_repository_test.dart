import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/infrastructure/repositories/in_memory_auth_repository.dart';

void main() {
  test('auth state emits user after Google sign-in and null after sign-out', () async {
    final repo = InMemoryAuthRepository();
    final events = <String?>[];
    final sub = repo.authStateChanges().listen((user) => events.add(user?.id));

    await repo.signInWithGoogle();
    await repo.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(events, ['local-google-user', null]);

    await sub.cancel();
  });
}
