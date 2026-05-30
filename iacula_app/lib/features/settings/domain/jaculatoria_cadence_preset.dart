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

  /// Maps a stored/legacy interval to the nearest preset.
  ///
  /// Thresholds: `<= 60 -> frequente`, `<= 120 -> regular`, else `suave`.
  static JaculatoriaCadencePreset fromIntervalMinutes(int minutes) {
    if (minutes <= 60) return JaculatoriaCadencePreset.frequente;
    if (minutes <= 120) return JaculatoriaCadencePreset.regular;
    return JaculatoriaCadencePreset.suave;
  }
}
