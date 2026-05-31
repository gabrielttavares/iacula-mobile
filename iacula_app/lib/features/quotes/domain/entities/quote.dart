import '../../../liturgical/domain/liturgical_season.dart';

enum QuoteSource { liturgical, personal, escrivaPoints }

final class Quote {
  const Quote({
    required this.text,
    required this.dayOfWeek,
    required this.theme,
    required this.season,
    this.imagePath,
    this.feast,
    this.feastName,
    this.source = QuoteSource.liturgical,
    this.referenceLabel,
  });

  final String text;
  final int dayOfWeek;
  final String theme;
  final LiturgicalSeason season;
  final String? imagePath;
  final String? feast;
  final String? feastName;
  final QuoteSource? source;
  final String? referenceLabel;

  /// A quote sourced from one of the user's own personal phrases. Personal
  /// phrases carry no season or imagery of their own, so they render as plain
  /// ordinary-time text.
  factory Quote.personal({required String text, required int dayOfWeek}) =>
      Quote(
        text: text,
        dayOfWeek: dayOfWeek,
        theme: 'personal',
        season: LiturgicalSeason.ordinary,
        source: QuoteSource.personal,
      );

  QuoteSource get resolvedSource => source ?? QuoteSource.liturgical;
}
