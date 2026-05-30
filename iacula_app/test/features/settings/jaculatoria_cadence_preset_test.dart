import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_cadence_preset.dart';

void main() {
  test('each preset persists a representative interval inside its bucket', () {
    expect(JaculatoriaCadencePreset.suave.intervalMinutes, 180);
    expect(JaculatoriaCadencePreset.regular.intervalMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.intervalMinutes, 60);
  });

  test('today cadence is the real slot spacing (2h / 90min / 1h)', () {
    expect(JaculatoriaCadencePreset.suave.todayCadenceMinutes, 120);
    expect(JaculatoriaCadencePreset.regular.todayCadenceMinutes, 90);
    expect(JaculatoriaCadencePreset.frequente.todayCadenceMinutes, 60);
  });

  test('minutes map to the nearest preset (migration thresholds)', () {
    // <= 60 -> Frequente
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(5),
        JaculatoriaCadencePreset.frequente);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(60),
        JaculatoriaCadencePreset.frequente);
    // <= 120 -> Regular
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(61),
        JaculatoriaCadencePreset.regular);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(120),
        JaculatoriaCadencePreset.regular);
    // > 120 -> Suave
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(121),
        JaculatoriaCadencePreset.suave);
    expect(JaculatoriaCadencePreset.fromIntervalMinutes(360),
        JaculatoriaCadencePreset.suave);
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
