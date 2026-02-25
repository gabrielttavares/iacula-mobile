import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/bootstrap/bootstrap_status.dart';

void main() {
  group('BootstrapStatus', () {
    test('defaults to all-local mode', () {
      const status = BootstrapStatus();
      expect(status.supabaseAvailable, false);
      expect(status.isLocalOnly, true);
      expect(status.authMode, AuthMode.local);
      expect(status.syncEnabled, false);
    });

    test('reports cloud mode when Supabase initialized', () {
      const status = BootstrapStatus(
        supabaseAvailable: true,
        authMode: AuthMode.supabase,
        syncEnabled: true,
      );
      expect(status.isLocalOnly, false);
    });

    test('reports partial when auth works but sync failed', () {
      const status = BootstrapStatus(
        supabaseAvailable: true,
        authMode: AuthMode.supabase,
        syncEnabled: false,
      );
      expect(status.isLocalOnly, false);
      expect(status.syncEnabled, false);
    });
  });
}
