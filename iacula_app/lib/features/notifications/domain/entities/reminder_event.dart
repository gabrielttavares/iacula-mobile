enum ReminderEventType {
  quoteInterval,
  angelusNoon,
  laudes,
  vespers,
  compline,
  oraMedia,
  customMeditationAlarm,
}

final class ReminderEvent {
  const ReminderEvent({
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.withVibration,
    required this.isAlarm,
    this.repeatDaily = false,
  });

  final ReminderEventType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool withVibration;
  final bool isAlarm;
  final bool repeatDaily;

  ReminderEvent copyWith({
    ReminderEventType? type,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? withVibration,
    bool? isAlarm,
    bool? repeatDaily,
  }) {
    return ReminderEvent(
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      withVibration: withVibration ?? this.withVibration,
      isAlarm: isAlarm ?? this.isAlarm,
      repeatDaily: repeatDaily ?? this.repeatDaily,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'body': body,
      'scheduledAt': scheduledAt.toIso8601String(),
      'withVibration': withVibration,
      'isAlarm': isAlarm,
      'repeatDaily': repeatDaily,
    };
  }

  static ReminderEvent fromMap(Map<String, dynamic> map) {
    final typeName = map['type']?.toString() ?? ReminderEventType.quoteInterval.name;
    final type = ReminderEventType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ReminderEventType.quoteInterval,
    );

    return ReminderEvent(
      type: type,
      title: map['title']?.toString() ?? 'Iacula',
      body: map['body']?.toString() ?? '',
      scheduledAt: DateTime.tryParse(map['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
      withVibration: map['withVibration'] == true,
      isAlarm: map['isAlarm'] == true,
      repeatDaily: map['repeatDaily'] == true,
    );
  }
}
