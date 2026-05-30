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

  testWidgets('renders all four presets in increasing-density order',
      (tester) async {
    await pumpSelector(tester, selected: JaculatoriaCadencePreset.frequente);

    for (final label in ['Suave', 'Regular', 'Frequente', 'Mais frequente']) {
      expect(find.text(label), findsOneWidget);
    }

    // Density order: their cards appear left-to-right in increasing frequency.
    final suaveX = tester.getCenter(find.text('Suave')).dx;
    final regularX = tester.getCenter(find.text('Regular')).dx;
    final frequenteX = tester.getCenter(find.text('Frequente')).dx;
    final maisX = tester.getCenter(find.text('Mais frequente')).dx;
    expect(suaveX, lessThan(regularX));
    expect(regularX, lessThan(frequenteX));
    expect(frequenteX, lessThan(maisX));
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
