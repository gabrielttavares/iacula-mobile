enum ChallengeCategory {
  novena,
  marian,
  lenten,
  advent,
  saints,
  general,
}

extension ChallengeCategoryX on ChallengeCategory {
  String get label => switch (this) {
    ChallengeCategory.novena => 'Novenas',
    ChallengeCategory.marian => 'Marianas',
    ChallengeCategory.lenten => 'Quaresma',
    ChallengeCategory.advent => 'Advento',
    ChallengeCategory.saints => 'Santos',
    ChallengeCategory.general => 'Geral',
  };
}

final class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.category,
    required this.content,
    this.imagePath,
  });

  final String id;
  final String title;
  final String description;
  final int durationDays;
  final ChallengeCategory category;
  final List<ChallengeDay> content;
  final String? imagePath;

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationDays: json['durationDays'] as int,
      category: ChallengeCategory.values.byName(json['category'] as String),
      imagePath: json['imagePath'] as String?,
      content: (json['content'] as List)
          .map((d) => ChallengeDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

final class ChallengeDay {
  const ChallengeDay({
    required this.dayNumber,
    required this.title,
    required this.readingText,
    required this.reflectionPrompt,
    this.prayerSlug,
  });

  final int dayNumber;
  final String title;
  final String readingText;
  final String reflectionPrompt;
  final String? prayerSlug;

  factory ChallengeDay.fromJson(Map<String, dynamic> json) {
    return ChallengeDay(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      readingText: json['readingText'] as String,
      reflectionPrompt: json['reflectionPrompt'] as String,
      prayerSlug: json['prayerSlug'] as String?,
    );
  }
}
