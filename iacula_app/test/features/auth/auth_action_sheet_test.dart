import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/widgets/iacula_spring_button.dart';
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
      return CupertinoApp(
        home: CupertinoPageScaffold(
          child: AuthActionSheet(
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

      final appleY = tester.getCenter(find.text('Continuar com Apple')).dy;
      final googleY = tester.getCenter(find.text('Continuar com Google')).dy;
      final microsoftY = tester
          .getCenter(find.text('Continuar com Microsoft'))
          .dy;

      expect(appleY < googleY, isTrue);
      expect(googleY < microsoftY, isTrue);
    });

    testWidgets('Non-iOS order: Google, Microsoft, and Apple absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSheet(platformOverride: TargetPlatform.android),
      );

      expect(find.text('Continuar com Google'), findsOneWidget);
      expect(find.text('Continuar com Microsoft'), findsOneWidget);
      expect(find.text('Continuar com Apple'), findsNothing);
    });

    testWidgets('Signed-in state hides provider buttons and shows sync active', (
      tester,
    ) async {
      await tester.pumpWidget(buildSheet(signedInEmail: 'test@example.com'));

      expect(find.text('Sincronização ativa'), findsOneWidget);
      expect(find.textContaining('test@example.com'), findsOneWidget);
      expect(find.text('Continuar com Google'), findsNothing);
      expect(find.text('Continuar com Microsoft'), findsNothing);
      expect(find.text('Continuar com Apple'), findsNothing);
    });

    testWidgets(
      'Loading state disables all provider buttons while one is running',
      (tester) async {
        final completer = Completer<void>();

        await tester.pumpWidget(
          buildSheet(
            platformOverride: TargetPlatform.iOS,
            onGoogle: () => completer.future,
          ),
        );

        await tester.tap(find.text('Continuar com Google'));
        await tester.pump();

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text('Continuar com Google'), findsNothing);

        final appleButton = tester.widget<IaculaSpringButton>(
          find
              .ancestor(
                of: find.text('Continuar com Apple'),
                matching: find.byType(IaculaSpringButton),
              )
              .first,
        );
        expect(appleButton.onTap, isNull);

        completer.complete();
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.text('Continuar com Google'), findsOneWidget);
      },
    );

    testWidgets('Error state displays inline message when callback throws', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSheet(
          onGoogle: () async {
            throw Exception('Failed to sign in');
          },
        ),
      );

      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Failed to sign in'), findsOneWidget);
    });
  });
}
