final class ComplineDay {
  const ComplineDay({
    required this.dayOfWeek,
    required this.psalms,
    required this.shortReading,
    required this.responsory,
    required this.canticle,
    required this.collect,
    required this.marianAntiphon,
  });

  final int dayOfWeek;
  final List<ComplinePsalm> psalms;
  final ComplineSection shortReading;
  final ComplineSection responsory;
  final ComplineSection canticle; // Nunc Dimittis
  final ComplineSection collect;
  final ComplineSection marianAntiphon;

  factory ComplineDay.fromJson(Map<String, dynamic> json) {
    return ComplineDay(
      dayOfWeek: json['dayOfWeek'] as int,
      psalms: (json['psalms'] as List)
          .map((p) => ComplinePsalm.fromJson(p as Map<String, dynamic>))
          .toList(),
      shortReading:
          ComplineSection.fromJson(json['shortReading'] as Map<String, dynamic>),
      responsory:
          ComplineSection.fromJson(json['responsory'] as Map<String, dynamic>),
      canticle:
          ComplineSection.fromJson(json['canticle'] as Map<String, dynamic>),
      collect:
          ComplineSection.fromJson(json['collect'] as Map<String, dynamic>),
      marianAntiphon:
          ComplineSection.fromJson(json['marianAntiphon'] as Map<String, dynamic>),
    );
  }
}

final class ComplinePsalm {
  const ComplinePsalm({
    required this.reference,
    required this.antiphon,
    required this.text,
  });

  final String reference;
  final String antiphon;
  final String text;

  factory ComplinePsalm.fromJson(Map<String, dynamic> json) {
    return ComplinePsalm(
      reference: json['reference'] as String,
      antiphon: json['antiphon'] as String,
      text: json['text'] as String,
    );
  }
}

final class ComplineSection {
  const ComplineSection({
    required this.title,
    required this.text,
    this.reference,
  });

  final String title;
  final String text;
  final String? reference;

  factory ComplineSection.fromJson(Map<String, dynamic> json) {
    return ComplineSection(
      title: json['title'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String?,
    );
  }
}
