import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/widgets/cadence_chip_selector.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_cadence_preset.dart';

Widget _host({
  required JaculatoriaCadencePreset selected,
  required ValueChanged<JaculatoriaCadencePreset> onChanged,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: CadenceChipSelector(selected: selected, onChanged: onChanged),
    ),
  );
}

void main() {
  // Regression: chips used to be defined by arbitrary minute values rerun
  // through fromIntervalMinutes. "2h" (120) and "1h30" (90) both bucketed to
  // `regular`, so tapping that chip highlighted two chips and scheduled 1h30.
  // The selector is now one chip per preset, labelled by its real cadence; the
  // gentlest preset (`suave`) delivers every 3h.

  testWidgets('shows exactly one chip per preset, labelled by real cadence',
      (tester) async {
    await tester.pumpWidget(
      _host(selected: JaculatoriaCadencePreset.suave, onChanged: (_) {}),
    );

    for (final label in const [
      '3h',
      '2h',
      '1h30',
      '1h',
      '30min',
      '15min',
      '10min',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'missing chip $label');
    }
  });

  testWidgets('each chip selects exactly its own preset', (tester) async {
    final taps = <JaculatoriaCadencePreset>[];
    await tester.pumpWidget(
      _host(
        selected: JaculatoriaCadencePreset.frequente,
        onChanged: taps.add,
      ),
    );

    // "3h" must report suave (the 3h preset).
    await tester.tap(find.text('3h'));
    expect(taps.last, JaculatoriaCadencePreset.suave);

    // "2h" must report moderado — distinct from both 3h and 1h30.
    await tester.tap(find.text('2h'));
    expect(taps.last, JaculatoriaCadencePreset.moderado);

    // "1h30" must report regular, distinct from the 2h chip.
    await tester.tap(find.text('1h30'));
    expect(taps.last, JaculatoriaCadencePreset.regular);

    await tester.tap(find.text('30min'));
    expect(taps.last, JaculatoriaCadencePreset.maisFrequente);
  });

  testWidgets('selecting suave highlights only its chip (no collision)',
      (tester) async {
    // With `suave` selected, only its chip ("3h") should render highlighted;
    // the old bug highlighted two chips at once.
    await tester.pumpWidget(
      _host(selected: JaculatoriaCadencePreset.suave, onChanged: (_) {}),
    );

    final highlighted = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .where((container) {
      final decoration = container.decoration as BoxDecoration;
      // Selected chips use the primaryButton fill; unselected use card.
      return decoration.color != null &&
          decoration.border?.top.color == decoration.color;
    });

    expect(highlighted, hasLength(1));
  });
}
