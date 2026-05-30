/// User-facing cadence presets for jaculatória quote notifications.
///
/// Each preset maps to a representative interval (minutes) that is persisted via
/// the existing `interval_minutes` column, so introducing presets needs no
/// storage migration. The preset drives both notification layers:
/// - the dense "today" one-shot layer (interval = [intervalMinutes]), and
/// - the weekly grid floor ([weeklyFloorSlotsPerWeekday] cells per weekday).
enum JaculatoriaCadencePreset {
  /// ~every 2h across the active window. Representative interval sits inside the
  /// suave bucket (> 135) so preset⇄minutes round-trips; the today layer treats
  /// it as a 120-min (2h) cadence (see [todayCadenceMinutes]).
  suave(intervalMinutes: 180),

  /// ~every 90min.
  regular(intervalMinutes: 90),

  /// ~every hour.
  frequente(intervalMinutes: 60),

  /// ~every 30min on the today layer. Dense-today-only: the weekly grid floor
  /// stays at 5/weekday, so this density applies only on days the app is opened
  /// (closed days fall back to the gentle floor like every other preset).
  maisFrequente(intervalMinutes: 30);

  const JaculatoriaCadencePreset({required this.intervalMinutes});

  /// Representative interval persisted via the existing settings field.
  final int intervalMinutes;

  /// Actual spacing (minutes) between today-layer slots for this preset.
  /// Suave = 2h, Regular = 90min, Frequente = 1h.
  int get todayCadenceMinutes => switch (this) {
        JaculatoriaCadencePreset.suave => 120,
        JaculatoriaCadencePreset.regular => 90,
        JaculatoriaCadencePreset.frequente => 60,
        JaculatoriaCadencePreset.maisFrequente => 30,
      };

  /// Weekly grid floor density (cells per weekday) — same for all presets.
  int get weeklyFloorSlotsPerWeekday => 5;

  /// pt-BR cadence label for a standalone subtitle (capitalized).
  /// Kept short so none of the 3 preset cards wraps onto a second line.
  String get cadenceLabelPtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'A cada 2h',
        JaculatoriaCadencePreset.regular => 'A cada 1h30',
        JaculatoriaCadencePreset.frequente => 'A cada hora',
        JaculatoriaCadencePreset.maisFrequente => 'A cada 30min',
      };

  /// pt-BR cadence phrase for inline use (lowercase), e.g.
  /// "Jaculatórias a cada hora e Angelus ao meio-dia.".
  String get cadencePhrasePtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'a cada 2 horas',
        JaculatoriaCadencePreset.regular => 'a cada 1h30',
        JaculatoriaCadencePreset.frequente => 'a cada hora',
        JaculatoriaCadencePreset.maisFrequente => 'a cada 30 minutos',
      };

  /// pt-BR honest description of the daily volume for the settings estimate.
  String get dailyVolumeDescriptionPtBr => switch (this) {
        JaculatoriaCadencePreset.suave =>
          'Cerca de 7 lembranças por dia, da manhã à noite.',
        JaculatoriaCadencePreset.regular =>
          'Cerca de 9 lembranças por dia.',
        JaculatoriaCadencePreset.frequente =>
          'Cerca de 13 lembranças por dia, de hora em hora.',
        JaculatoriaCadencePreset.maisFrequente =>
          'Cerca de 24 lembranças por dia — só nos dias em que você abre o app.',
      };

  /// Maps a stored/legacy interval to the nearest preset.
  ///
  /// Thresholds (midpoints between adjacent representative intervals 30/60/90/
  /// 180): `<= 45 -> maisFrequente`, `<= 75 -> frequente`, `<= 135 -> regular`,
  /// else `suave`. Each preset's representative interval lands in its own band,
  /// so preset⇄minutes round-trips without collision.
  static JaculatoriaCadencePreset fromIntervalMinutes(int minutes) {
    if (minutes <= 45) return JaculatoriaCadencePreset.maisFrequente;
    if (minutes <= 75) return JaculatoriaCadencePreset.frequente;
    if (minutes <= 135) return JaculatoriaCadencePreset.regular;
    return JaculatoriaCadencePreset.suave;
  }
}
