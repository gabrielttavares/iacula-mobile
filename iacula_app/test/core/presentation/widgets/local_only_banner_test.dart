import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/bootstrap/bootstrap_status.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/widgets/local_only_banner.dart';

void main() {
  testWidgets('shows nothing when Supabase is available', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootstrapStatusProvider.overrideWithValue(
            const BootstrapStatus(supabaseAvailable: true, authMode: AuthMode.supabase, syncEnabled: true),
          ),
        ],
        child: const CupertinoApp(home: LocalOnlyBanner()),
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('shows warning banner when in local-only mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootstrapStatusProvider.overrideWithValue(const BootstrapStatus()),
        ],
        child: const CupertinoApp(home: LocalOnlyBanner()),
      ),
    );
    expect(find.textContaining('modo local'), findsOneWidget);
  });
}
