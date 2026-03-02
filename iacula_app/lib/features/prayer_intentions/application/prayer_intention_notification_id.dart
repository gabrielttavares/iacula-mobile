// lib/features/prayer_intentions/application/prayer_intention_notification_id.dart

int prayerIntentionNotificationId(String intentionId) {
  return 5000 + (intentionId.hashCode & 0x3FFF);
}
