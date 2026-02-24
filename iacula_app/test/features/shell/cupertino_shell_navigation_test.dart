import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';

void main() {
  testWidgets('shell uses CupertinoTabScaffold with five tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          localizationsDelegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR'), Locale('en')],
          home: ShellScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Meditação'), findsOneWidget);
    expect(find.text('Plano de vida'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('shell switches to profile tab', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          localizationsDelegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR'), Locale('en')],
          home: ShellScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.text('Perfil'));
    await tester.pump(const Duration(milliseconds: 350));

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    expect(tabBar.currentIndex, 4);
    expect(find.text('Dados da conta'), findsOneWidget);
  });
}
