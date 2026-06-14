/// User-facing cadence presets for jaculatória quote notifications.
///
/// Each preset maps to a representative interval (minutes) that is persisted via
/// the existing `interval_minutes` column, so introducing presets needs no
/// storage migration. The preset drives the pre-rolled multi-day quote queue:
/// the cadence ([todayCadenceMinutes]) is the spacing between quote slots. How
/// far that cadence reaches while the app stays closed depends on the platform
/// notification capacity (iOS caps pending notifications; Android does not).
enum JaculatoriaCadencePreset {
  /// ~every 3h across the active window. The representative interval (180) and
  /// the real cadence ([todayCadenceMinutes]) now agree at 3h, and 180 sits in
  /// the suave bucket (> 135) so preset⇄minutes round-trips.
  suave(intervalMinutes: 180),

  /// ~every 90min.
  regular(intervalMinutes: 90),

  /// ~every hour.
  frequente(intervalMinutes: 60),

  /// ~every 30min.
  maisFrequente(intervalMinutes: 30),

  /// ~every 15min.
  intenso(intervalMinutes: 15),

  /// ~every 10min. The tightest cadence offered. On iOS the per-day pending cap
  /// means closed-app delivery is best-effort (a limited number spread across
  /// the day); on Android the chosen cadence is honored closed-app.
  muitoIntenso(intervalMinutes: 10);

  const JaculatoriaCadencePreset({required this.intervalMinutes});

  /// Representative interval persisted via the existing settings field.
  final int intervalMinutes;

  /// Actual spacing (minutes) between quote slots for this preset.
  int get todayCadenceMinutes => switch (this) {
        JaculatoriaCadencePreset.suave => 180,
        JaculatoriaCadencePreset.regular => 90,
        JaculatoriaCadencePreset.frequente => 60,
        JaculatoriaCadencePreset.maisFrequente => 30,
        JaculatoriaCadencePreset.intenso => 15,
        JaculatoriaCadencePreset.muitoIntenso => 10,
      };

  /// Whether this cadence is tight enough that the OS pending-notification cap
  /// limits how much of it can be delivered while the app stays closed. Drives
  /// the explanatory note in settings; the Step-2 scheduler will read the same
  /// predicate so the UI and scheduling logic agree on which presets are
  /// constrained.
  bool get isClosedAppCapConstrained => todayCadenceMinutes <= 15;

  /// Short pt-BR display name for the preset card (the cadence itself is shown
  /// as the subtitle via [cadenceLabelPtBr]).
  String get displayNamePtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'Suave',
        JaculatoriaCadencePreset.regular => 'Regular',
        JaculatoriaCadencePreset.frequente => 'Frequente',
        JaculatoriaCadencePreset.maisFrequente => 'Mais frequente',
        JaculatoriaCadencePreset.intenso => 'Intenso',
        JaculatoriaCadencePreset.muitoIntenso => 'Muito intenso',
      };

  /// pt-BR cadence label for a standalone subtitle (capitalized).
  /// Kept short so no preset card wraps onto a second line.
  String get cadenceLabelPtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'A cada 3h',
        JaculatoriaCadencePreset.regular => 'A cada 1h30',
        JaculatoriaCadencePreset.frequente => 'A cada hora',
        JaculatoriaCadencePreset.maisFrequente => 'A cada 30min',
        JaculatoriaCadencePreset.intenso => 'A cada 15min',
        JaculatoriaCadencePreset.muitoIntenso => 'A cada 10min',
      };

  /// pt-BR cadence phrase for inline use (lowercase), e.g.
  /// "Jaculatórias a cada hora e Angelus ao meio-dia.".
  String get cadencePhrasePtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'a cada 3 horas',
        JaculatoriaCadencePreset.regular => 'a cada 1h30',
        JaculatoriaCadencePreset.frequente => 'a cada hora',
        JaculatoriaCadencePreset.maisFrequente => 'a cada 30 minutos',
        JaculatoriaCadencePreset.intenso => 'a cada 15 minutos',
        JaculatoriaCadencePreset.muitoIntenso => 'a cada 10 minutos',
      };

  /// Maps a stored/legacy interval to the nearest preset.
  ///
  /// Thresholds are midpoints between adjacent representative intervals
  /// (10/15/30/60/90/180): `<= 12 -> muitoIntenso`, `<= 22 -> intenso`,
  /// `<= 45 -> maisFrequente`, `<= 75 -> frequente`, `<= 135 -> regular`,
  /// else `suave`. Each preset's representative interval lands in its own band,
  /// so preset⇄minutes round-trips without collision.
  static JaculatoriaCadencePreset fromIntervalMinutes(int minutes) {
    if (minutes <= 12) return JaculatoriaCadencePreset.muitoIntenso;
    if (minutes <= 22) return JaculatoriaCadencePreset.intenso;
    if (minutes <= 45) return JaculatoriaCadencePreset.maisFrequente;
    if (minutes <= 75) return JaculatoriaCadencePreset.frequente;
    if (minutes <= 135) return JaculatoriaCadencePreset.regular;
    return JaculatoriaCadencePreset.suave;
  }
}
