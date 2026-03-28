import '../../auth/domain/entities/auth_user.dart';

/// Neutral welcome copy for the home nav large title (personalized name, no gendered "bem-vindo/vinda").
String homeLargeTitleGreeting({
  required AuthUser? user,
  required String? localDisplayName,
}) {
  final name = _firstNonEmptyTrimmed([
    user?.displayName,
    localDisplayName,
  ]);
  if (name == null) {
    return 'Olá!';
  }
  return 'Olá, $name!';
}

String? _firstNonEmptyTrimmed(List<String?> values) {
  for (final raw in values) {
    final t = raw?.trim();
    if (t != null && t.isNotEmpty) {
      return t;
    }
  }
  return null;
}
