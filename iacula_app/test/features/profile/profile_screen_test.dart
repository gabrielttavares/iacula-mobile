import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/profile/presentation/profile_screen.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('profile renders sections and opens settings subroute', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: CupertinoApp(home: ProfileScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Conta'), findsWidgets);
    expect(find.text('Privacidade e segurança'), findsOneWidget);
    final settingsRow = find.textContaining('Configura');
    for (var i = 0; i < 10 && settingsRow.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -220));
      await tester.pumpAndSettle();
    }
    expect(settingsRow, findsOneWidget);

    await tester.tap(settingsRow);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
