import 'dart:io' show Platform;

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthUser?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name']?.toString(),
    );
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name']?.toString(),
      );
    });
  }

  @override
  Future<void> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signInWithMicrosoft() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.azure,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signInWithApple() {
    if (!Platform.isIOS) {
      throw UnsupportedError('Apple sign-in is iOS-only.');
    }
    return _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
