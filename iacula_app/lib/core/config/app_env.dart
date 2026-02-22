final class AppEnv {
  const AppEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.authSyncEnabled,
  });

  final String? supabaseUrl;
  final String? supabaseAnonKey;
  final bool authSyncEnabled;

  bool get hasSupabase =>
      (supabaseUrl?.isNotEmpty ?? false) && (supabaseAnonKey?.isNotEmpty ?? false);

  static AppEnv fromDartDefines() {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    const authSyncEnabled = String.fromEnvironment(
      'AUTH_SYNC_ENABLED',
      defaultValue: 'false',
    );

    return AppEnv(
      supabaseUrl: supabaseUrl.isEmpty ? null : supabaseUrl,
      supabaseAnonKey: supabaseAnonKey.isEmpty ? null : supabaseAnonKey,
      authSyncEnabled: authSyncEnabled.toLowerCase() == 'true',
    );
  }
}
