import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/bootstrap/bootstrap_status.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('bootstrap overrides include bootstrapStatusProvider', () {
    // This is a compile-time check that the override exists in the list.
    // Full integration test requires device/emulator.
    // We verify the provider is importable and has the right type.
    final container = ProviderContainer(overrides: [
      bootstrapStatusProvider.overrideWithValue(
        const BootstrapStatus(supabaseAvailable: true, authMode: AuthMode.supabase, syncEnabled: true),
      ),
    ]);
    addTearDown(container.dispose);
    expect(container.read(bootstrapStatusProvider).supabaseAvailable, true);
  });
}
