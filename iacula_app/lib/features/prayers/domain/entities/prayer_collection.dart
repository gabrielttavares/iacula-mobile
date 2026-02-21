import 'prayer.dart';

final class PrayerCollection {
  const PrayerCollection({
    required this.regularTitle,
    required this.regularVerses,
    required this.regularPrayer,
    required this.easterTitle,
    required this.easterVerses,
    required this.easterPrayer,
  });

  final String regularTitle;
  final List<PrayerVerse> regularVerses;
  final String regularPrayer;

  final String easterTitle;
  final List<PrayerVerse> easterVerses;
  final String easterPrayer;
}
