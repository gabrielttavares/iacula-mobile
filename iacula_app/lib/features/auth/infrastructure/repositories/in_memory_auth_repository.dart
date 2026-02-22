import 'dart:async';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AuthUser? seed}) : _value = seed;

  AuthUser? _value;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Future<AuthUser?> currentUser() async => _value;

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

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
