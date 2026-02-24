import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iacula_app/app/app.dart';

void main() {
  testWidgets('renderiza onboarding no primeiro launch', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IaculaApp()));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.text('Começar com sua conta'), findsOneWidget);
  });
}
