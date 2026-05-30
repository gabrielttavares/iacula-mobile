import 'dart:convert';

import 'reminder_event.dart';

final class NotificationActionEvent {
  const NotificationActionEvent({required this.actionId, required this.event});

  final String? actionId;
  final ReminderEvent event;

  static const String prayNowAction = 'pray_now';
  static const String snooze1hAction = 'snooze_1h';
  static const String dismissAction = 'dismiss';

  /// "Rezei" — a one-tap engagement action: the user marks that they prayed.
  /// Opens the app, records today's prayer (feeding the streak), and confirms.
  static const String rezeiAction = 'rezei';

  static const String openAction = 'open_now';
  static const String snooze10Action = 'snooze_10';

  String toPayload() {
    return jsonEncode({'actionId': actionId, 'event': event.toMap()});
  }

  static NotificationActionEvent? fromPayload(
    String? payload, {
    String? fallbackActionId,
  }) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final eventMap = map['event'] as Map<String, dynamic>?;
      if (eventMap == null) return null;
      return NotificationActionEvent(
        actionId: fallbackActionId ?? map['actionId']?.toString(),
        event: ReminderEvent.fromMap(eventMap),
      );
    } catch (_) {
      return null;
    }
  }
}
