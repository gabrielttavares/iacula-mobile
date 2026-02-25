import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/bootstrap/bootstrap_status.dart';
import 'package:iacula_app/core/di/providers.dart';

void main() {
  test('bootstrapStatusProvider defaults to local-only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final status = container.read(bootstrapStatusProvider);
    expect(status.isLocalOnly, true);
  });

  test('bootstrapStatusProvider can be overridden with cloud status', () {
    final container = ProviderContainer(
      overrides: [
        bootstrapStatusProvider.overrideWithValue(
          const BootstrapStatus(
            supabaseAvailable: true,
            authMode: AuthMode.supabase,
            syncEnabled: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final status = container.read(bootstrapStatusProvider);
    expect(status.isLocalOnly, false);
    expect(status.syncEnabled, true);
  });
}
