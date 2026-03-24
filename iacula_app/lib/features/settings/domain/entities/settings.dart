final class Settings {
  const Settings({
    required this.intervalMinutes,
    required this.durationSeconds,
    required this.autostart,
    required this.language,
    required this.liturgyReminderSoundEnabled,
    required this.liturgyReminderSoundVolume,
    required this.laudesEnabled,
    required this.vespersEnabled,
    required this.complineEnabled,
    required this.oraMediaEnabled,
    required this.laudesTime,
    required this.vespersTime,
    required this.complineTime,
    required this.oraMediaTime,
    required this.onboardingCompleted,
    this.displayName,
    this.prayerFontSize = 15.0,
    this.themeMode = 'dark',
    this.escrivaPointsFeedEnabled = false,
    this.notificationsEnabled = true,
    this.angelusEnabled = true,
  });

  final int intervalMinutes;
  final int durationSeconds;
  final bool autostart;
  final String language;
  final bool liturgyReminderSoundEnabled;
  final double liturgyReminderSoundVolume;
  final bool laudesEnabled;
  final bool vespersEnabled;
  final bool complineEnabled;
  final bool oraMediaEnabled;
  final String laudesTime;
  final String vespersTime;
  final String complineTime;
  final String oraMediaTime;
  final bool onboardingCompleted;
  final String? displayName;
  final double prayerFontSize;
  final String themeMode;
  final bool escrivaPointsFeedEnabled;
  final bool notificationsEnabled;
  final bool angelusEnabled;

  static const defaults = Settings(
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
    prayerFontSize: 15.0,
    escrivaPointsFeedEnabled: false,
    notificationsEnabled: true,
    angelusEnabled: true,
  );

  Settings copyWith({
    int? intervalMinutes,
    int? durationSeconds,
    bool? autostart,
    String? language,
    bool? liturgyReminderSoundEnabled,
    double? liturgyReminderSoundVolume,
    bool? laudesEnabled,
    bool? vespersEnabled,
    bool? complineEnabled,
    bool? oraMediaEnabled,
    String? laudesTime,
    String? vespersTime,
    String? complineTime,
    String? oraMediaTime,
    bool? onboardingCompleted,
    String? displayName,
    double? prayerFontSize,
    String? themeMode,
    bool? escrivaPointsFeedEnabled,
    bool? notificationsEnabled,
    bool? angelusEnabled,
  }) {
    return Settings(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      autostart: autostart ?? this.autostart,
      language: language ?? this.language,
      liturgyReminderSoundEnabled:
          liturgyReminderSoundEnabled ?? this.liturgyReminderSoundEnabled,
      liturgyReminderSoundVolume:
          liturgyReminderSoundVolume ?? this.liturgyReminderSoundVolume,
      laudesEnabled: laudesEnabled ?? this.laudesEnabled,
      vespersEnabled: vespersEnabled ?? this.vespersEnabled,
      complineEnabled: complineEnabled ?? this.complineEnabled,
      oraMediaEnabled: oraMediaEnabled ?? this.oraMediaEnabled,
      laudesTime: laudesTime ?? this.laudesTime,
      vespersTime: vespersTime ?? this.vespersTime,
      complineTime: complineTime ?? this.complineTime,
      oraMediaTime: oraMediaTime ?? this.oraMediaTime,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      displayName: displayName ?? this.displayName,
      prayerFontSize: prayerFontSize ?? this.prayerFontSize,
      themeMode: themeMode ?? this.themeMode,
      escrivaPointsFeedEnabled:
          escrivaPointsFeedEnabled ?? this.escrivaPointsFeedEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      angelusEnabled: angelusEnabled ?? this.angelusEnabled,
    );
  }
}
