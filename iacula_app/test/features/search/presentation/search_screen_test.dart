import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/search/presentation/search_screen.dart';

void main() {
  testWidgets('shows search field', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('shows empty state before searching', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Busque no app'), findsOneWidget);
    expect(
      find.text(
        'Procure por uma oração, meditação, leitura ou citação.',
      ),
      findsOneWidget,
    );
  });
}
