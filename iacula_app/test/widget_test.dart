import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iacula_app/app/app.dart';

void main() {
  testWidgets('renderiza shell inicial do Iacula', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IaculaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Iacula'), findsOneWidget);
  });
}
