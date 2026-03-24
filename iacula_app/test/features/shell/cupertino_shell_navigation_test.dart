import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';

void main() {
  testWidgets('shell uses CupertinoTabScaffold with four tabs', (tester) async {
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
    expect(find.text('Exame Diário'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Mais'), findsOneWidget);
  });

  testWidgets('shell switches to more tab', (tester) async {
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

    await tester.tap(find.text('Mais'));
    await tester.pump(const Duration(milliseconds: 350));

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    expect(tabBar.currentIndex, 3);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Configurações'), findsOneWidget);
  });

  testWidgets('retapping the active Home tab pops its nested stack', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

    await tester.tap(find.byKey(const Key('home_notifications_button')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    tabBar.onTap!(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(NotificationsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('retapping Home at root keeps shell stable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    tabBar.onTap!(0);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
