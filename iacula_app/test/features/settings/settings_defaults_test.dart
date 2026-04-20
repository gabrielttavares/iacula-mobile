import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  test('settings defaults map from electron baseline', () {
    expect(Settings.defaults.intervalMinutes, 15);
    expect(Settings.defaults.durationSeconds, 10);
    expect(Settings.defaults.language, 'pt-br');
    expect(Settings.defaults.laudesTime, '06:00');
    expect(Settings.defaults.onboardingCompleted, isFalse);
    expect(Settings.defaults.themeMode, 'system');
    expect(Settings.defaults.quietHoursEnabled, isFalse);
    expect(Settings.defaults.quietHoursStart, '22:00');
    expect(Settings.defaults.quietHoursEnd, '07:00');
  });

  test('Settings optional constructor defaults for new installs', () {
    const partial = Settings(
      intervalMinutes: 15,
      durationSeconds: 10,
      autostart: true,
      language: 'pt-br',
      liturgyReminderSoundEnabled: true,
      liturgyReminderSoundVolume: 0.35,
      laudesEnabled: false,
      vespersEnabled: false,
      complineEnabled: false,
      oraMediaEnabled: false,
      laudesTime: '06:00',
      vespersTime: '18:00',
      complineTime: '21:00',
      oraMediaTime: '12:30',
      onboardingCompleted: false,
    );
    expect(partial.themeMode, 'system');
    expect(partial.quietHoursEnabled, isFalse);
    expect(partial.quietHoursStart, '22:00');
    expect(partial.quietHoursEnd, '07:00');
  });
}
