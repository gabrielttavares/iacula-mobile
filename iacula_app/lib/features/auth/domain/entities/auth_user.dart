enum AuthProviderType {
  google,
  microsoft,
  apple,
}

enum Gender {
  male,
  female,
}

final class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.gender,
  });

  final String id;
  final String email;
  final String? displayName;
  final Gender? gender;
}
