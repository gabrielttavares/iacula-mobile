final class PrayerVerse {
  const PrayerVerse({required this.verse, required this.response});

  final String verse;
  final String response;
}

final class Prayer {
  const Prayer({
    required this.title,
    required this.verses,
    required this.prayer,
    required this.type,
    this.imagePath,
  });

  final String title;
  final List<PrayerVerse> verses;
  final String prayer;
  final String type;
  final String? imagePath;
}
