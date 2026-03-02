enum PhraseScheduleType { daily, weekly, specificDates }

final class PhraseSchedule {
  const PhraseSchedule({
    required this.type,
    this.daysOfWeek = const [],
    this.specificDates = const [],
    this.times = const [],
  });

  final PhraseScheduleType type;
  final List<int> daysOfWeek; // 1–7 (Mon–Sun), for weekly
  final List<String> specificDates; // ISO date strings, for specificDates
  final List<String> times; // "HH:mm" strings

  bool matchesNow(DateTime now) {
    // Check if current date matches schedule
    switch (type) {
      case PhraseScheduleType.daily:
        return true;
      case PhraseScheduleType.weekly:
        return daysOfWeek.contains(now.weekday);
      case PhraseScheduleType.specificDates:
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        return specificDates.any((d) => d.startsWith(dateStr));
    }
  }

  String summary() {
    final timesStr = times.join(', ');
    switch (type) {
      case PhraseScheduleType.daily:
        return 'Todos os dias às $timesStr';
      case PhraseScheduleType.weekly:
        final days = daysOfWeek.map((d) => _dayName(d)).join(', ');
        return '$days às $timesStr';
      case PhraseScheduleType.specificDates:
        final dates = specificDates
            .map((d) {
              final parts = d.split('-');
              if (parts.length < 3) return d;
              return '${parts[2].substring(0, 2)}/${parts[1]}';
            })
            .join(', ');
        return '$dates às $timesStr';
    }
  }

  static String _dayName(int day) {
    return switch (day) {
      DateTime.monday => 'Seg',
      DateTime.tuesday => 'Ter',
      DateTime.wednesday => 'Qua',
      DateTime.thursday => 'Qui',
      DateTime.friday => 'Sex',
      DateTime.saturday => 'Sáb',
      DateTime.sunday => 'Dom',
      _ => '',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'daysOfWeek': daysOfWeek,
      'specificDates': specificDates,
      'times': times,
    };
  }

  factory PhraseSchedule.fromJson(Map<String, dynamic> json) {
    return PhraseSchedule(
      type: PhraseScheduleType.values.byName(json['type'] as String),
      daysOfWeek: List<int>.from(json['daysOfWeek'] as List),
      specificDates: List<String>.from(json['specificDates'] as List),
      times: List<String>.from(json['times'] as List),
    );
  }
}
