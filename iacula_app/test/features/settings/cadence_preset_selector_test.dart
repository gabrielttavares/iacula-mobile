import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/widgets/cadence_preset_selector.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_cadence_preset.dart';

void main() {
  Future<void> pumpSelector(
    WidgetTester tester, {
    required JaculatoriaCadencePreset selected,
  }) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: CadencePresetSelector(
              selected: selected,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all four presets in a density-ordered 2x2 grid',
      (tester) async {
    await pumpSelector(tester, selected: JaculatoriaCadencePreset.frequente);

    for (final label in ['Suave', 'Regular', 'Frequente', 'Mais frequente']) {
      expect(find.text(label), findsOneWidget);
    }

    final suaveCenter = tester.getCenter(find.text('Suave'));
    final regularCenter = tester.getCenter(find.text('Regular'));
    final frequenteCenter = tester.getCenter(find.text('Frequente'));
    final maisCenter = tester.getCenter(find.text('Mais frequente'));

    // 2x2 grid in increasing-density reading order:
    // row 1: Suave (left) , Regular (right)
    // row 2: Frequente (left), Mais frequente (right)
    expect(suaveCenter.dx, lessThan(regularCenter.dx)); // row 1 left-to-right
    expect(frequenteCenter.dx, lessThan(maisCenter.dx)); // row 2 left-to-right
    expect(suaveCenter.dy, lessThan(frequenteCenter.dy)); // left column top-to-bottom
    expect(regularCenter.dy, lessThan(maisCenter.dy)); // right column top-to-bottom
  });

  testWidgets('Mais frequente card shows the 30-min cadence subtitle',
      (tester) async {
    await pumpSelector(
      tester,
      selected: JaculatoriaCadencePreset.maisFrequente,
    );

    expect(find.text('A cada 30min'), findsOneWidget);
  });
}
