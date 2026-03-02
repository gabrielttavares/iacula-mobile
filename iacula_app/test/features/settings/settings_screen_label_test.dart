// test/features/settings/settings_screen_label_test.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('settings screen labels sections correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Liturgia das Horas section removed
    expect(find.text('Liturgia das Horas'), findsNothing);

    // New section headers present
    expect(find.text('Aparência'), findsOneWidget);

    final notifFinder = find.text('Notificações');
    for (var i = 0; i < 20 && notifFinder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(notifFinder, findsOneWidget);
  });
}
