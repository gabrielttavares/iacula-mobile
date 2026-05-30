import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/quote.dart';
import 'last_delivered_card.dart';

final class NotificationHistoryEntry {
  const NotificationHistoryEntry({
    required this.quoteText,
    required this.theme,
    required this.season,
    required this.deliveredAt,
    this.imagePath,
    this.feastName,
    this.source,
    this.referenceLabel,
  });

  final String quoteText;
  final String theme;
  final String season;
  final DateTime deliveredAt;
  final String? imagePath;
  final String? feastName;
  final String? source;
  final String? referenceLabel;

  factory NotificationHistoryEntry.fromLastDeliveredCard(LastDeliveredCard card) {
    return NotificationHistoryEntry(
      quoteText: card.quoteText,
      theme: card.theme,
      season: card.season,
      deliveredAt: card.deliveredAt,
      imagePath: card.imagePath,
      feastName: card.feastName,
      source: card.source,
      referenceLabel: card.referenceLabel,
    );
  }

  /// Records the quote scheduled/delivered at [deliveredAt]. Used both for real
  /// deliveries (the immediate notification) and for today-layer slot
  /// assignments cached at their fire time.
  factory NotificationHistoryEntry.fromQuote(
    Quote quote, {
    required DateTime deliveredAt,
  }) {
    return NotificationHistoryEntry(
      quoteText: quote.text,
      theme: quote.theme,
      season: quote.season.name,
      deliveredAt: deliveredAt,
      imagePath: quote.imagePath,
      feastName: quote.feastName,
      source: quote.resolvedSource.name,
      referenceLabel: quote.referenceLabel,
    );
  }

  /// Reconstructs the [Quote] this entry recorded. [dayOfWeek] is supplied by
  /// the caller because the entry only stores the fire instant, not the bucket.
  Quote toQuote({required int dayOfWeek}) {
    return Quote(
      text: quoteText,
      dayOfWeek: dayOfWeek,
      theme: theme,
      season: LiturgicalSeason.values.firstWhere(
        (candidate) => candidate.name == season,
        orElse: () => LiturgicalSeason.ordinary,
      ),
      imagePath: imagePath,
      feastName: feastName,
      source: QuoteSource.values.firstWhere(
        (candidate) => candidate.name == source,
        orElse: () => QuoteSource.liturgical,
      ),
      referenceLabel: referenceLabel,
    );
  }
}
