import 'dart:convert';

class PlanItemSchedule {
  const PlanItemSchedule({
    this.time,
    required this.daysOfWeek,
    required this.notify,
    this.isDefault = false,
  });

  final String? time;
  final List<int> daysOfWeek; // 1 (Monday) to 7 (Sunday)
  final bool notify;
  final bool isDefault;

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'daysOfWeek': daysOfWeek,
      'notify': notify,
      'isDefault': isDefault,
    };
  }

  factory PlanItemSchedule.fromMap(Map<String, dynamic> map) {
    return PlanItemSchedule(
      time: map['time'] as String?,
      daysOfWeek: List<int>.from(map['daysOfWeek'] as List? ?? []),
      notify: map['notify'] as bool? ?? false,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanItemSchedule.fromJson(String source) =>
      PlanItemSchedule.fromMap(json.decode(source) as Map<String, dynamic>);
}
