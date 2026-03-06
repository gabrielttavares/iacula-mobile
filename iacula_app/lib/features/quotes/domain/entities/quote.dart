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

  QuoteSource get resolvedSource => source ?? QuoteSource.liturgical;
}
