import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/infrastructure/repositories/in_memory_auth_repository.dart';

void main() {
  test('authStateChanges emits current session immediately (null when signed out)', () async {
    final repo = InMemoryAuthRepository();
    final first = await repo.authStateChanges().first;
    expect(first, isNull);
  });

  test('authStateChanges emits updates after sign-in', () async {
    final repo = InMemoryAuthRepository();
    final events = <String?>[];
    final sub = repo.authStateChanges().listen((u) => events.add(u?.displayName));
    await Future<void>.delayed(Duration.zero);
    expect(events, [null]);

    await repo.signInWithGoogle();
    await Future<void>.delayed(Duration.zero);
    expect(events.last, 'Local Google');

    await sub.cancel();
  });
}
