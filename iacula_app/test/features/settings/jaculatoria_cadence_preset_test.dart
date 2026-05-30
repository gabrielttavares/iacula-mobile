import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_cadence_preset.dart';

void main() {
  test('each preset persists a representative interval inside its bucket', () {
    expect(JaculatoriaCadencePreset.suave.intervalMinutes, 180);
    expect(JaculatoriaCadencePreset.regular.intervalMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.intervalMinutes, 60);
    expect(JaculatoriaCadencePreset.maisFrequente.intervalMinutes, 30);
  });

  test('today cadence is the real slot spacing (2h / 90min / 1h / 30min)', () {
    expect(JaculatoriaCadencePreset.suave.todayCadenceMinutes, 120);
    expect(JaculatoriaCadencePreset.regular.todayCadenceMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.todayCadenceMinutes, 60);
    expect(JaculatoriaCadencePreset.maisFrequente.todayCadenceMinutes, 30);
  });

  test('minutes map to the nearest preset (migration thresholds)', () {
    // <= 45 -> Mais frequente
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(5),
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

  test('weekly floor is 5 slots per weekday for every preset', () {
    for (final preset in JaculatoriaCadencePreset.values) {
      expect(preset.weeklyFloorSlotsPerWeekday, 5);
    }
  });
}
