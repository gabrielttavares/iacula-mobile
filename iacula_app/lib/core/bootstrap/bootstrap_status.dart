enum AuthMode { local, supabase }

final class BootstrapStatus {
  const BootstrapStatus({
    this.supabaseAvailable = false,
    this.authMode = AuthMode.local,
    this.syncEnabled = false,
    this.errorMessage,
  });

  final bool supabaseAvailable;
  final AuthMode authMode;
  final bool syncEnabled;
  final String? errorMessage;

  bool get isLocalOnly => !supabaseAvailable;
}
