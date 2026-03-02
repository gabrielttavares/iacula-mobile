enum JournalMood {
  consolation,
  desolation,
  neutral,
}

extension JournalMoodX on JournalMood {
  String get label => switch (this) {
    JournalMood.consolation => 'Consolação',
    JournalMood.desolation => 'Desolação',
    JournalMood.neutral => 'Neutro',
  };

  String get emoji => switch (this) {
    JournalMood.consolation => '☀️',
    JournalMood.desolation => '🌧️',
    JournalMood.neutral => '☁️',
  };
}

final class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.tags = const [],
    this.mood,
    this.liturgicalSeason,
    this.deletedAt,
  });

  final String id;
  final String? title;
  final String body;
  final List<String> tags;
  final JournalMood? mood;
  final String? liturgicalSeason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  JournalEntry copyWith({
    String? title,
    String? body,
    List<String>? tags,
    JournalMood? mood,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      liturgicalSeason: liturgicalSeason,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
