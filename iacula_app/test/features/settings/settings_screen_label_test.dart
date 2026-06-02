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

    Future<void> scrollTo(Finder finder) async {
      for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    }

    // New section headers present (scroll to them — the settings list is taller
    // than the test viewport now that the active-window block is always shown).
    final notifFinder = find.text('Notificações');
    await scrollTo(notifFinder);
    expect(notifFinder, findsOneWidget);

    final aparenciaFinder = find.text('Aparência');
    await scrollTo(aparenciaFinder);
    expect(aparenciaFinder, findsOneWidget);
  });
}
