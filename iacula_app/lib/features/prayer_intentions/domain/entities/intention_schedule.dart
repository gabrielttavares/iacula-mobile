enum IntentionScheduleType { daily, weekly, specificDates }

final class IntentionSchedule {
  const IntentionSchedule({
    required this.type,
    this.daysOfWeek = const [],
    this.specificDates = const [],
    this.times = const [],
  });

  final IntentionScheduleType type;
  final List<int> daysOfWeek;
  final List<String> specificDates;
  final List<String> times;

  bool matchesNow(DateTime now) {
    switch (type) {
      case IntentionScheduleType.daily:
        return true;
      case IntentionScheduleType.weekly:
        return daysOfWeek.contains(now.weekday);
      case IntentionScheduleType.specificDates:
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        return specificDates.any((d) => d.startsWith(dateStr));
    }
  }

  String summary() {
    final timesStr = times.join(', ');
    switch (type) {
      case IntentionScheduleType.daily:
        return times.isEmpty ? 'Todos os dias' : 'Todos os dias às $timesStr';
      case IntentionScheduleType.weekly:
        final days = daysOfWeek.map((d) => _dayName(d)).join(', ');
        return times.isEmpty ? days : '$days às $timesStr';
      case IntentionScheduleType.specificDates:
        final dates = specificDates
            .map((d) {
              final parts = d.split('-');
              if (parts.length < 3) return d;
              return '${parts[2].substring(0, 2)}/${parts[1]}';
            })
            .join(', ');
        return times.isEmpty ? dates : '$dates às $timesStr';
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

  factory IntentionSchedule.fromJson(Map<String, dynamic> json) {
    return IntentionSchedule(
      type: IntentionScheduleType.values.byName(json['type'] as String),
      daysOfWeek: List<int>.from(json['daysOfWeek'] as List? ?? []),
      specificDates: List<String>.from(json['specificDates'] as List? ?? []),
      times: List<String>.from(json['times'] as List? ?? []),
    );
  }

  IntentionSchedule copyWith({
    IntentionScheduleType? type,
    List<int>? daysOfWeek,
    List<String>? specificDates,
    List<String>? times,
  }) {
    return IntentionSchedule(
      type: type ?? this.type,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      specificDates: specificDates ?? this.specificDates,
      times: times ?? this.times,
    );
  }
}
