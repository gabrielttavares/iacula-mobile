import '../../../liturgical/domain/liturgical_season.dart';

final class Quote {
  const Quote({
    required this.text,
    required this.dayOfWeek,
    required this.theme,
    required this.season,
    this.imagePath,
    this.feast,
    this.feastName,
  });

  final String text;
  final int dayOfWeek;
  final String theme;
  final LiturgicalSeason season;
  final String? imagePath;
  final String? feast;
  final String? feastName;
}
