/// User-facing cadence presets for jaculatória quote notifications.
///
/// Each preset maps to a representative interval (minutes) that is persisted via
/// the existing `interval_minutes` column, so introducing presets needs no
/// storage migration. The preset drives both notification layers:
/// - the dense "today" one-shot layer (interval = [intervalMinutes]), and
/// - the weekly grid floor ([weeklyFloorSlotsPerWeekday] cells per weekday).
enum JaculatoriaCadencePreset {
  /// ~every 2h across the active window. Representative interval sits inside the
  /// suave bucket (> 120) so preset⇄minutes round-trips; the today layer treats
  /// it as a 120-min (2h) cadence (see [todayCadenceMinutes]).
  suave(intervalMinutes: 180),

  /// ~every 90min.
  regular(intervalMinutes: 90),

  /// ~every hour.
  frequente(intervalMinutes: 60);

  const JaculatoriaCadencePreset({required this.intervalMinutes});

  /// Representative interval persisted via the existing settings field.
  final int intervalMinutes;

  /// Actual spacing (minutes) between today-layer slots for this preset.
  /// Suave = 2h, Regular = 90min, Frequente = 1h.
  int get todayCadenceMinutes => switch (this) {
        JaculatoriaCadencePreset.suave => 120,
        JaculatoriaCadencePreset.regular => 90,
        JaculatoriaCadencePreset.frequente => 60,
      };

  /// Weekly grid floor density (cells per weekday) — same for all presets.
  int get weeklyFloorSlotsPerWeekday => 5;

  /// pt-BR cadence label for a standalone subtitle (capitalized).
  /// Kept short so none of the 3 preset cards wraps onto a second line.
  String get cadenceLabelPtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'A cada 2h',
        JaculatoriaCadencePreset.regular => 'A cada 1h30',
        JaculatoriaCadencePreset.frequente => 'A cada hora',
      };

  /// pt-BR cadence phrase for inline use (lowercase), e.g.
  /// "Jaculatórias a cada hora e Angelus ao meio-dia.".
  String get cadencePhrasePtBr => switch (this) {
        JaculatoriaCadencePreset.suave => 'a cada 2 horas',
        JaculatoriaCadencePreset.regular => 'a cada 1h30',
        JaculatoriaCadencePreset.frequente => 'a cada hora',
      };

  /// pt-BR honest description of the daily volume for the settings estimate.
  String get dailyVolumeDescriptionPtBr => switch (this) {
        JaculatoriaCadencePreset.suave =>
          'Cerca de 7 lembranças por dia, da manhã à noite.',
        JaculatoriaCadencePreset.regular =>
          'Cerca de 9 lembranças por dia.',
        JaculatoriaCadencePreset.frequente =>
          'Cerca de 13 lembranças por dia, de hora em hora.',
      };

  /// Maps a stored/legacy interval to the nearest preset.
  ///
  /// Thresholds: `<= 60 -> frequente`, `<= 120 -> regular`, else `suave`.
  static JaculatoriaCadencePreset fromIntervalMinutes(int minutes) {
    if (minutes <= 60) return JaculatoriaCadencePreset.frequente;
    if (minutes <= 120) return JaculatoriaCadencePreset.regular;
    return JaculatoriaCadencePreset.suave;
  }
}
