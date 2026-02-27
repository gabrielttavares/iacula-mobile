import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/plan_of_life/presentation/widgets/plan_item_row.dart';

void main() {
  testWidgets('shows schedule summary and edit action', (tester) async {
    var toggled = false;
    var edited = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PlanItemRow(
            title: 'Oferecimento de obras',
            scheduleSummary: 'Todos os dias • 07:00',
            isCompleted: false,
            onToggle: (_) => toggled = true,
            onEdit: () => edited = true,
          ),
        ),
      ),
    );

    expect(find.text('Todos os dias • 07:00'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.ellipsis_circle), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle));
    await tester.pump();
    expect(edited, isTrue);
    expect(toggled, isFalse);
  });
}
