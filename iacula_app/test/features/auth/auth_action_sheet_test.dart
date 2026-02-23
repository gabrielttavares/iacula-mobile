import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/presentation/auth_action_sheet.dart';

void main() {
  group('AuthActionSheet', () {
    const title = 'Test Title';
    const subtitle = 'Test Subtitle';

    Widget buildSheet({
      String? signedInEmail,
      TargetPlatform? platformOverride,
      Future<void> Function()? onGoogle,
      Future<void> Function()? onMicrosoft,
      Future<void> Function()? onApple,
      Future<void> Function()? onSignOut,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AuthActionSheet(
            title: title,
            subtitle: subtitle,
            signedInEmail: signedInEmail,
            platformOverride: platformOverride,
            onGoogle: onGoogle ?? () async {},
            onMicrosoft: onMicrosoft ?? () async {},
            onApple: onApple ?? () async {},
            onSignOut: onSignOut ?? () async {},
          ),
        ),
      );
    }

    testWidgets('iOS order: Apple, Google, Microsoft', (tester) async {
      await tester.pumpWidget(buildSheet(platformOverride: TargetPlatform.iOS));

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);

      final buttons = tester.widgetList<Text>(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is OutlinedButton || widget is FilledButton || widget is ElevatedButton),
          matching: find.byType(Text),
        ),
      ).toList();

      expect(buttons.length, 3);
      expect(buttons[0].data, 'Continuar com Apple');
      expect(buttons[1].data, 'Continuar com Google');
      expect(buttons[2].data, 'Continuar com Microsoft');
    });

    testWidgets('Non-iOS order: Google, Microsoft, and Apple absent', (tester) async {
      await tester.pumpWidget(buildSheet(platformOverride: TargetPlatform.android));

      final buttons = tester.widgetList<Text>(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is OutlinedButton || widget is FilledButton || widget is ElevatedButton),
          matching: find.byType(Text),
        ),
      ).toList();

      expect(buttons.length, 2);
      expect(buttons[0].data, 'Continuar com Google');
      expect(buttons[1].data, 'Continuar com Microsoft');
      expect(find.text('Continuar com Apple'), findsNothing);
    });

    testWidgets('Signed-in state hides provider buttons and shows sign-out', (tester) async {
      await tester.pumpWidget(buildSheet(signedInEmail: 'test@example.com'));

      expect(find.text('Conectado como test@example.com'), findsOneWidget);
      expect(find.text('Sair da conta'), findsOneWidget);
      
      expect(find.text('Continuar com Google'), findsNothing);
      expect(find.text('Continuar com Microsoft'), findsNothing);
      expect(find.text('Continuar com Apple'), findsNothing);
    });

    testWidgets('Loading state disables all provider buttons while one is running', (tester) async {
      final completer = Completer<void>();
      
      await tester.pumpWidget(buildSheet(
        platformOverride: TargetPlatform.iOS,
        onGoogle: () => completer.future,
      ));

      await tester.tap(find.text('Continuar com Google'));
      await tester.pump();

      // CircularProgressIndicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The text of the active button is hidden when busy
      expect(find.text('Continuar com Google'), findsNothing);
      
      // Try to tap another button, shouldn't do anything because buttons are disabled
      // In Flutter, onPressed being null disables the button. We can test this by checking
      // if the OutlinedButton has null onPressed.
      final appleBtn = tester.widget<FilledButton>(
        find.ancestor(of: find.text('Continuar com Apple'), matching: find.byType(FilledButton))
      );
      expect(appleBtn.onPressed, isNull);

      completer.complete();
      await tester.pumpAndSettle();

      // Should be back to normal
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Continuar com Google'), findsOneWidget);
    });

    testWidgets('Error state displays inline message when callback throws', (tester) async {
      await tester.pumpWidget(buildSheet(
        onGoogle: () async { throw Exception('Failed to sign in'); },
      ));

      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Failed to sign in'), findsOneWidget);
    });
  });
}
