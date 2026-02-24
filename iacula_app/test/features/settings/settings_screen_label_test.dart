// test/features/settings/settings_screen_label_test.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('settings screen labels liturgy section correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liturgia das Horas'), findsOneWidget);
    expect(find.text('Segurança'), findsNothing);
  });
}
