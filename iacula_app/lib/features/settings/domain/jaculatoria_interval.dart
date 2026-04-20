/// Intervalo permitido para notificações de jaculatória (minutos).
const int kJaculatoriaIntervalMin = 5;

/// 6 horas
const int kJaculatoriaIntervalMax = 360;

/// Preset de intervalo para seleção de notificações.
class IntervalPreset {
  final int minutes;
  final String label;
  final bool isCommon;

  const IntervalPreset({
    required this.minutes,
    required this.label,
    this.isCommon = false,
  });
}

/// Presets de intervalo disponíveis.
/// `isCommon: true` são exibidos nos botões principais.
/// Outros estão disponíveis no seletor personalizado.
const kIntervalPresets = [
  // Comuns (botões principais)
  IntervalPreset(minutes: 5, label: '5 min', isCommon: true),
  IntervalPreset(minutes: 15, label: '15 min', isCommon: true),
  IntervalPreset(minutes: 30, label: '30 min', isCommon: true),
  IntervalPreset(minutes: 60, label: '1 hora', isCommon: true),
  IntervalPreset(minutes: 120, label: '2 horas', isCommon: true),
  IntervalPreset(minutes: 180, label: '3 horas', isCommon: true),

  // Extendidos (disponíveis no picker)
  IntervalPreset(minutes: 45, label: '45 min'),
  IntervalPreset(minutes: 90, label: '1h30'),
  IntervalPreset(minutes: 240, label: '4 horas'),
  IntervalPreset(minutes: 300, label: '5 horas'),
  IntervalPreset(minutes: 360, label: '6 horas'),
];

int clampJaculatoriaIntervalMinutes(int value) {
  return value.clamp(kJaculatoriaIntervalMin, kJaculatoriaIntervalMax);
}

/// Rótulo curto para slider e resumos (ex.: "5 min", "1h", "1h20").
String formatJaculatoriaIntervalShortLabel(int minutes) {
  final m = clampJaculatoriaIntervalMinutes(minutes);
  if (m < 60) return '$m min';
  if (m == 60) return '1h';
  final h = m ~/ 60;
  final rem = m % 60;
  return '${h}h${rem.toString().padLeft(2, '0')}';
}

/// Frase "a cada …" para textos corridos em PT.
String formatJaculatoriaIntervalEveryPhrase(int minutes) {
  final m = clampJaculatoriaIntervalMinutes(minutes);
  if (m < 60) return 'a cada $m minutos';
  if (m == 60) return 'a cada hora';
  final h = m ~/ 60;
  final rem = m % 60;
  final horaWord = h == 1 ? 'hora' : 'horas';
  if (rem == 0) return 'a cada $h $horaWord';
  final minutoWord = rem == 1 ? 'minuto' : 'minutos';
  return 'a cada $h $horaWord e $rem $minutoWord';
}

/// Formato compacto tipo badge (ex.: linha inicial com "15min", "1h20").
String formatJaculatoriaIntervalCompactForBadge(int minutes) {
  final m = clampJaculatoriaIntervalMinutes(minutes);
  if (m < 60) return '${m}min';
  if (m == 60) return '1h';
  final h = m ~/ 60;
  final rem = m % 60;
  return '${h}h${rem.toString().padLeft(2, '0')}';
}
