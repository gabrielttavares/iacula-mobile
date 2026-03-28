import 'dart:async';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Development-only auth repository that creates fake local users.
///
/// Used when Supabase is unavailable or not configured.
/// Sign-in "succeeds" instantly with hardcoded credentials:
/// - Google: `local@google.dev`
/// - Microsoft: `local@outlook.dev`
/// - Apple: `local@apple.dev`
///
/// **This should never be active in production builds.**
/// See [SupabaseAuthRepository] for the real implementation.
final class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AuthUser? seed}) : _value = seed {
    assert(() {
      // ignore: avoid_print
      print('\u26a0\ufe0f  InMemoryAuthRepository active \u2014 auth is mocked');
      return true;
    }());
  }

  AuthUser? _value;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Future<AuthUser?> currentUser() async => _value;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _value;
    yield* _controller.stream;
  }

  @override
  Future<void> signInWithGoogle() async {
    _value = const AuthUser(id: 'local-google-user', email: 'local@google.dev', displayName: 'Local Google');
    _controller.add(_value);
  }

  @override
  Future<void> signInWithMicrosoft() async {
    _value = const AuthUser(
      id: 'local-microsoft-user',
      email: 'local@outlook.dev',
      displayName: 'Local Microsoft',
    );
    _controller.add(_value);
  }

  @override
  Future<void> signInWithApple() async {
    _value = const AuthUser(id: 'local-apple-user', email: 'local@apple.dev', displayName: 'Local Apple');
    _controller.add(_value);
  }

  @override
  Future<void> signOut() async {
    _value = null;
    _controller.add(null);
  }
}
