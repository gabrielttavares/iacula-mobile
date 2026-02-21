import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  test('settings defaults map from electron baseline', () {
    expect(Settings.defaults.intervalMinutes, 15);
    expect(Settings.defaults.durationSeconds, 10);
    expect(Settings.defaults.language, 'pt-br');
    expect(Settings.defaults.laudesTime, '06:00');
  });
}
