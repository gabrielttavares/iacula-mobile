import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/jaculatoria_interval.dart';

void main() {
  group('clampJaculatoriaIntervalMinutes', () {
    test('clamps below min to 5', () {
      expect(clampJaculatoriaIntervalMinutes(1), 5);
      expect(clampJaculatoriaIntervalMinutes(4), 5);
    });

    test('clamps above max to 360 (6h)', () {
      expect(clampJaculatoriaIntervalMinutes(361), kJaculatoriaIntervalMax);
      expect(clampJaculatoriaIntervalMinutes(1000), kJaculatoriaIntervalMax);
    });

    test('leaves values in range unchanged', () {
      expect(clampJaculatoriaIntervalMinutes(5), 5);
      expect(clampJaculatoriaIntervalMinutes(42), 42);
      // Preset representatives must survive the clamp untouched.
      expect(clampJaculatoriaIntervalMinutes(180), 180); // Suave
      expect(clampJaculatoriaIntervalMinutes(360), 360);
    });
  });

  group('formatJaculatoriaIntervalShortLabel', () {
    test('uses minutes below 60', () {
      expect(formatJaculatoriaIntervalShortLabel(5), '5 min');
      expect(formatJaculatoriaIntervalShortLabel(59), '59 min');
    });

    test('uses 1h for exactly 60', () {
      expect(formatJaculatoriaIntervalShortLabel(60), '1h');
    });

    test('uses hours and minutes for 61 to 80', () {
      expect(formatJaculatoriaIntervalShortLabel(61), '1h01');
      expect(formatJaculatoriaIntervalShortLabel(65), '1h05');
      expect(formatJaculatoriaIntervalShortLabel(80), '1h20');
    });
  });

  group('formatJaculatoriaIntervalEveryPhrase', () {
    test('a cada N minutos below 60', () {
      expect(formatJaculatoriaIntervalEveryPhrase(5), 'a cada 5 minutos');
      expect(formatJaculatoriaIntervalEveryPhrase(30), 'a cada 30 minutos');
    });

    test('a cada hora for 60', () {
      expect(formatJaculatoriaIntervalEveryPhrase(60), 'a cada hora');
    });

    test('a cada 1 hora e N minutos above 60', () {
      expect(
        formatJaculatoriaIntervalEveryPhrase(61),
        'a cada 1 hora e 1 minuto',
      );
      expect(
        formatJaculatoriaIntervalEveryPhrase(65),
        'a cada 1 hora e 5 minutos',
      );
      expect(
        formatJaculatoriaIntervalEveryPhrase(80),
        'a cada 1 hora e 20 minutos',
      );
    });
  });

  group('formatJaculatoriaIntervalCompactForBadge', () {
    test('compact form for home/notifications line', () {
      expect(formatJaculatoriaIntervalCompactForBadge(15), '15min');
      expect(formatJaculatoriaIntervalCompactForBadge(60), '1h');
      expect(formatJaculatoriaIntervalCompactForBadge(80), '1h20');
    });
  });
}
