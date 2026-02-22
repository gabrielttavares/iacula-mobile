import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> currentUser();
  Stream<AuthUser?> authStateChanges();
  Future<void> signInWithGoogle();
  Future<void> signInWithMicrosoft();
  Future<void> signInWithApple();
  Future<void> signOut();
}
