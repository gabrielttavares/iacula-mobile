import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgy_hours/presentation/liturgy_hours_landing_screen.dart';

void main() {
  testWidgets('does not show liturgical season label', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(home: LiturgyHoursLandingScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Tempo do'), findsNothing);
    expect(find.text('Tempo Comum'), findsNothing);
  });
}
