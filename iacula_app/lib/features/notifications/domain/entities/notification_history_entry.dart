import 'last_delivered_card.dart';

final class NotificationHistoryEntry {
  const NotificationHistoryEntry({
    required this.quoteText,
    required this.theme,
    required this.season,
    required this.deliveredAt,
    this.imagePath,
    this.feastName,
  });

  final String quoteText;
  final String theme;
  final String season;
  final DateTime deliveredAt;
  final String? imagePath;
  final String? feastName;

  factory NotificationHistoryEntry.fromLastDeliveredCard(LastDeliveredCard card) {
    return NotificationHistoryEntry(
      quoteText: card.quoteText,
      theme: card.theme,
      season: card.season,
      deliveredAt: card.deliveredAt,
      imagePath: card.imagePath,
      feastName: card.feastName,
    );
  }
}
