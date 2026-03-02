enum LiturgicalHourType {
  laudes,
  tercia,
  sexta,
  noa,
  vesperas,
  leituras,
}

extension LiturgicalHourTypeX on LiturgicalHourType {
  String get label => switch (this) {
    LiturgicalHourType.laudes => 'Laudes',
    LiturgicalHourType.tercia => 'Tércia',
    LiturgicalHourType.sexta => 'Sexta',
    LiturgicalHourType.noa => 'Noa',
    LiturgicalHourType.vesperas => 'Vésperas',
    LiturgicalHourType.leituras => 'Ofício das Leituras',
  };

  String get timeHint => switch (this) {
    LiturgicalHourType.laudes => '06:00',
    LiturgicalHourType.tercia => '09:00',
    LiturgicalHourType.sexta => '12:00',
    LiturgicalHourType.noa => '15:00',
    LiturgicalHourType.vesperas => '18:00',
    LiturgicalHourType.leituras => 'Qualquer hora',
  };
}

final class LiturgicalHour {
  const LiturgicalHour({
    required this.type,
    required this.psalterWeek,
    required this.dayOfWeek,
    required this.sections,
  });

  final LiturgicalHourType type;
  final int psalterWeek; // 1-4
  final int dayOfWeek; // 1-7
  final List<HourSection> sections;

  factory LiturgicalHour.fromJson(Map<String, dynamic> json) {
    return LiturgicalHour(
      type: LiturgicalHourType.values.byName(json['type'] as String),
      psalterWeek: json['psalterWeek'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      sections: (json['sections'] as List)
          .map((s) => HourSection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum HourSectionType {
  invitatory,
  hymn,
  psalm,
  reading,
  responsory,
  canticle,
  intercessions,
  collect,
}

final class HourSection {
  const HourSection({
    required this.type,
    required this.title,
    required this.content,
    this.antiphon,
    this.reference,
  });

  final HourSectionType type;
  final String title;
  final String content;
  final String? antiphon;
  final String? reference;

  factory HourSection.fromJson(Map<String, dynamic> json) {
    return HourSection(
      type: HourSectionType.values.byName(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      antiphon: json['antiphon'] as String?,
      reference: json['reference'] as String?,
    );
  }
}
