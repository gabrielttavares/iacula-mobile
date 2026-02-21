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
  });

  final String quoteText;
  final String theme;
  final String season;
  final DateTime deliveredAt;
  final String? imagePath;
  final String? feast;
  final String? feastName;

  Quote toQuote() {
    return Quote(
      text: quoteText,
      dayOfWeek: 1,
      theme: theme,
      season: _parseSeason(season),
      imagePath: imagePath,
      feast: feast,
      feastName: feastName,
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
    );
  }

  static LiturgicalSeason _parseSeason(String value) {
    return LiturgicalSeason.values.firstWhere(
      (season) => season.name == value,
      orElse: () => LiturgicalSeason.ordinary,
    );
  }
}
