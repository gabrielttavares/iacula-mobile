enum RosaryMysteryType {
  joyful, // Gozosos — Mon/Sat
  sorrowful, // Dolorosos — Tue/Fri
  glorious, // Gloriosos — Wed/Sun
  luminous, // Luminosos — Thu
}

extension RosaryMysteryTypeX on RosaryMysteryType {
  String get label => switch (this) {
    RosaryMysteryType.joyful => 'Mistérios Gozosos',
    RosaryMysteryType.sorrowful => 'Mistérios Dolorosos',
    RosaryMysteryType.glorious => 'Mistérios Gloriosos',
    RosaryMysteryType.luminous => 'Mistérios Luminosos',
  };

  String get shortLabel => switch (this) {
    RosaryMysteryType.joyful => 'Gozosos',
    RosaryMysteryType.sorrowful => 'Dolorosos',
    RosaryMysteryType.glorious => 'Gloriosos',
    RosaryMysteryType.luminous => 'Luminosos',
  };

  List<int> get dayOfWeek => switch (this) {
    RosaryMysteryType.joyful => [DateTime.monday, DateTime.saturday],
    RosaryMysteryType.sorrowful => [DateTime.tuesday, DateTime.friday],
    RosaryMysteryType.glorious => [DateTime.wednesday, DateTime.sunday],
    RosaryMysteryType.luminous => [DateTime.thursday],
  };

  static RosaryMysteryType forDay(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday || DateTime.saturday => RosaryMysteryType.joyful,
      DateTime.tuesday || DateTime.friday => RosaryMysteryType.sorrowful,
      DateTime.wednesday || DateTime.sunday => RosaryMysteryType.glorious,
      DateTime.thursday => RosaryMysteryType.luminous,
      _ => RosaryMysteryType.joyful,
    };
  }
}

final class RosaryMysterySet {
  const RosaryMysterySet({
    required this.type,
    required this.mysteries,
    this.setImagePath,
  });

  final RosaryMysteryType type;
  final List<RosaryMystery> mysteries;
  final String? setImagePath;

  factory RosaryMysterySet.fromJson(Map<String, dynamic> json) {
    return RosaryMysterySet(
      type: RosaryMysteryType.values.byName(json['type'] as String),
      mysteries: (json['mysteries'] as List)
          .map((m) => RosaryMystery.fromJson(m as Map<String, dynamic>))
          .toList(),
      setImagePath: json['setImagePath'] as String?,
    );
  }
}

final class RosaryMystery {
  const RosaryMystery({
    required this.name,
    required this.fruit,
    required this.scriptureRef,
    required this.scriptureText,
    required this.meditationText,
    this.imagePath,
  });

  final String name;
  final String fruit;
  final String scriptureRef;
  final String scriptureText;
  final String meditationText;
  final String? imagePath;

  factory RosaryMystery.fromJson(Map<String, dynamic> json) {
    return RosaryMystery(
      name: json['name'] as String,
      fruit: json['fruit'] as String,
      scriptureRef: json['scriptureRef'] as String,
      scriptureText: json['scriptureText'] as String,
      meditationText: json['meditationText'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }
}
