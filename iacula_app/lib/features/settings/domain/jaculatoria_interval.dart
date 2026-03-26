/// Intervalo permitido para notificações de jaculatória (minutos).
const int kJaculatoriaIntervalMin = 5;

/// 1h20
const int kJaculatoriaIntervalMax = 80;

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
