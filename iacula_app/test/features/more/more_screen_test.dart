import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/more/presentation/more_screen.dart';
import 'package:iacula_app/features/profile/presentation/profile_screen.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';
import 'package:iacula_app/features/favorites/presentation/favorites_screen.dart';
import 'package:iacula_app/features/bible/presentation/bible_books_screen.dart';

void main() {
  testWidgets('MoreScreen renders all 8 items', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mais'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('Reportar problema'), findsOneWidget);
    expect(find.text('Avaliar experiência'), findsOneWidget);
    
    expect(find.text('Favoritos'), findsNothing);
    expect(find.text('Bíblia'), findsNothing);
  });

  testWidgets('MoreScreen navigates to Perfil', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('MoreScreen navigates to Configurações', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: MoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
