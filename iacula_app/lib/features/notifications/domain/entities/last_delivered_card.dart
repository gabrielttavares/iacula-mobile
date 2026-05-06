import '../../../liturgical/domain/liturgical_season.dart';
import '../../../quotes/domain/entities/quote.dart';

final class LastDeliveredCard {
  const LastDeliveredCard({
    required this.quoteText,
    required this.theme,
    required this.season,
    required this.deliveredAt,
    this.imagePath,
    this.feast,
    this.feastName,
    this.source,
    this.referenceLabel,
  });

  final String quoteText;
  final String theme;
  final String season;
  final DateTime deliveredAt;
  final String? imagePath;
  final String? feast;
  final String? feastName;
  final String? source;
  final String? referenceLabel;

  Quote toQuote() {
    final parsedSource = _parseSource(source);
    return Quote(
      text: quoteText,
      dayOfWeek: 1,
      theme: theme,
      season: _parseSeason(season),
      imagePath: imagePath,
      feast: feast,
      feastName: feastName,
      source: parsedSource ??
          (referenceLabel != null ? QuoteSource.escrivaPoints : null),
      referenceLabel: referenceLabel,
    );
  }

  static LastDeliveredCard fromQuote(Quote quote, {required DateTime deliveredAt}) {
    return LastDeliveredCard(
      quoteText: quote.text,
      theme: quote.theme,
      season: quote.season.name,
      deliveredAt: deliveredAt,
      imagePath: quote.imagePath,
      feast: quote.feast,
      feastName: quote.feastName,
      source: quote.resolvedSource.name,
      referenceLabel: quote.referenceLabel,
    );
  }

  static LiturgicalSeason _parseSeason(String value) {
    return LiturgicalSeason.values.firstWhere(
      (season) => season.name == value,
      orElse: () => LiturgicalSeason.ordinary,
    );
  }

  static QuoteSource? _parseSource(String? value) {
    if (value == null) return null;
    return QuoteSource.values.firstWhere(
      (s) => s.name == value,
      orElse: () => QuoteSource.liturgical,
    );
  }
}
