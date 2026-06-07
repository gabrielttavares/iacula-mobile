import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_cadence_preset.dart';

void main() {
  test('each preset persists a representative interval inside its bucket', () {
    expect(JaculatoriaCadencePreset.suave.intervalMinutes, 180);
    expect(JaculatoriaCadencePreset.regular.intervalMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.intervalMinutes, 60);
    expect(JaculatoriaCadencePreset.maisFrequente.intervalMinutes, 30);
    expect(JaculatoriaCadencePreset.intenso.intervalMinutes, 15);
    expect(JaculatoriaCadencePreset.muitoIntenso.intervalMinutes, 10);
  });

  test('today cadence is the real slot spacing', () {
    expect(JaculatoriaCadencePreset.suave.todayCadenceMinutes, 120);
    expect(JaculatoriaCadencePreset.regular.todayCadenceMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.todayCadenceMinutes, 60);
    expect(JaculatoriaCadencePreset.maisFrequente.todayCadenceMinutes, 30);
    expect(JaculatoriaCadencePreset.intenso.todayCadenceMinutes, 15);
    expect(JaculatoriaCadencePreset.muitoIntenso.todayCadenceMinutes, 10);
  });

  test('minutes map to the nearest preset (migration thresholds)', () {
    // <= 12 -> Muito intenso (10min)
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(5),
        JaculatoriaCadencePreset.muitoIntenso);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(10),
        JaculatoriaCadencePreset.muitoIntenso);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(12),
        JaculatoriaCadencePreset.muitoIntenso);
    // <= 22 -> Intenso (15min)
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(13),
        JaculatoriaCadencePreset.intenso);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(15),
        JaculatoriaCadencePreset.intenso);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(22),
        JaculatoriaCadencePreset.intenso);
    // <= 45 -> Mais frequente (30min)
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(23),
        JaculatoriaCadencePreset.maisFrequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(30),
        JaculatoriaCadencePreset.maisFrequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(45),
        JaculatoriaCadencePreset.maisFrequente);
    // <= 75 -> Frequente
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(46),
        JaculatoriaCadencePreset.frequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(60),
        JaculatoriaCadencePreset.frequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(75),
        JaculatoriaCadencePreset.frequente);
    // <= 135 -> Regular
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(76),
        JaculatoriaCadencePreset.regular);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(90),
        JaculatoriaCadencePreset.regular);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(135),
        JaculatoriaCadencePreset.regular);
    // > 135 -> Suave
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(136),
        JaculatoriaCadencePreset.suave);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(180),
        JaculatoriaCadencePreset.suave);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(360),
        JaculatoriaCadencePreset.suave);
  });

  test('legacy custom intervals migrate to the nearest preset', () {
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(40),
        JaculatoriaCadencePreset.maisFrequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(50),
        JaculatoriaCadencePreset.frequente);
  });

  test('preset round-trips through its representative interval', () {
    for (final preset in JaculatoriaCadencePreset.values) {
      expect(
        JaculatoriaCadencePreset.fromIntervalMinutes(preset.intervalMinutes),
        preset,
      );
    }
  });

  test('every preset exposes a non-empty pt-BR label and phrase', () {
    for (final preset in JaculatoriaCadencePreset.values) {
      expect(preset.cadenceLabelPtBr, isNotEmpty);
      expect(preset.cadencePhrasePtBr, isNotEmpty);
    }
  });
}
