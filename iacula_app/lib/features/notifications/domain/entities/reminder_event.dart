enum ReminderEventType {
  quoteInterval,
  angelusNoon,
  laudes,
  vespers,
  compline,
  oraMedia,
  customPhrase,
  prayerIntentionReminder,
}

enum NotificationRouteTarget {
  home,
  prayer,
  alarm,
  prayerIntention,
  nightPrayer,
  liturgyHours,
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
    this.routeTarget = NotificationRouteTarget.alarm,
    this.scheduledId,
    this.intentionId,
    this.quoteTheme,
    this.quoteSeason,
    this.quoteFeastName,
  });

  final ReminderEventType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool withVibration;
  final bool isAlarm;
  final bool repeatDaily;
  final NotificationRouteTarget routeTarget;
  /// When set, used as the notification id (e.g. for per-intention reminders).
  final int? scheduledId;
  /// Optional intention id for prayer intention reminders (snooze, routing).
  final String? intentionId;
  final String? quoteTheme;
  final String? quoteSeason;
  final String? quoteFeastName;

  ReminderEvent copyWith({
    ReminderEventType? type,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? withVibration,
    bool? isAlarm,
    bool? repeatDaily,
    NotificationRouteTarget? routeTarget,
    int? scheduledId,
    String? intentionId,
    String? quoteTheme,
    String? quoteSeason,
    String? quoteFeastName,
  }) {
    return ReminderEvent(
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      withVibration: withVibration ?? this.withVibration,
      isAlarm: isAlarm ?? this.isAlarm,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      routeTarget: routeTarget ?? this.routeTarget,
      scheduledId: scheduledId ?? this.scheduledId,
      intentionId: intentionId ?? this.intentionId,
      quoteTheme: quoteTheme ?? this.quoteTheme,
      quoteSeason: quoteSeason ?? this.quoteSeason,
      quoteFeastName: quoteFeastName ?? this.quoteFeastName,
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
      'routeTarget': routeTarget.name,
      if (scheduledId != null) 'scheduledId': scheduledId,
      if (intentionId != null) 'intentionId': intentionId,
      if (quoteTheme != null) 'quoteTheme': quoteTheme,
      if (quoteSeason != null) 'quoteSeason': quoteSeason,
      if (quoteFeastName != null) 'quoteFeastName': quoteFeastName,
    };
  }

  static ReminderEvent fromMap(Map<String, dynamic> map) {
    final typeName = map['type']?.toString() ?? ReminderEventType.quoteInterval.name;
    final type = ReminderEventType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ReminderEventType.quoteInterval,
    );

    final routeTargetName = map['routeTarget']?.toString();
    final routeTarget = NotificationRouteTarget.values.firstWhere(
      (e) => e.name == routeTargetName,
      orElse: () => _defaultRouteForType(type),
    );

    final scheduledId = map['scheduledId'];
    final intentionId = map['intentionId']?.toString();
    int? sid;
    if (scheduledId is int) {
      sid = scheduledId;
    } else if (scheduledId is num) {
      sid = (scheduledId as num).toInt();
    }

    return ReminderEvent(
      type: type,
      title: map['title']?.toString() ?? 'Iacula',
      body: map['body']?.toString() ?? '',
      scheduledAt: DateTime.tryParse(map['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
      withVibration: map['withVibration'] == true,
      isAlarm: map['isAlarm'] == true,
      repeatDaily: map['repeatDaily'] == true,
      routeTarget: routeTarget,
      scheduledId: sid,
      intentionId: intentionId,
      quoteTheme: map['quoteTheme']?.toString(),
      quoteSeason: map['quoteSeason']?.toString(),
      quoteFeastName: map['quoteFeastName']?.toString(),
    );
  }

  static NotificationRouteTarget _defaultRouteForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => NotificationRouteTarget.home,
      ReminderEventType.angelusNoon => NotificationRouteTarget.prayer,
      ReminderEventType.laudes ||
      ReminderEventType.vespers => NotificationRouteTarget.liturgyHours,
      ReminderEventType.compline => NotificationRouteTarget.nightPrayer,
      ReminderEventType.oraMedia || ReminderEventType.customPhrase =>
        NotificationRouteTarget.home,
      ReminderEventType.prayerIntentionReminder => NotificationRouteTarget.prayerIntention,
    };
  }
}
