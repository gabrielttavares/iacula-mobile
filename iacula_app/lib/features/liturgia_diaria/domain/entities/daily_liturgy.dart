enum LiturgyColor { green, red, purple, pink, white }

enum LiturgyReadingKind {
  first,
  psalm,
  second,
  sequence,
  acclamation,
  gospel,
  other,
}

final class LiturgyPrayer {
  const LiturgyPrayer({
    required this.collect,
    required this.offering,
    required this.communion,
    this.extra = const <String>[],
  });

  final String collect;
  final String offering;
  final String communion;
  final List<String> extra;
}

final class LiturgyReading {
  const LiturgyReading({
    required this.reference,
    required this.title,
    required this.text,
    this.response,
    this.kind = LiturgyReadingKind.other,
  });

  final String reference;
  final String title;
  final String text;
  final String? response;
  final LiturgyReadingKind kind;
}

final class LiturgyAntiphons {
  const LiturgyAntiphons({
    this.entry,
    this.communion,
    this.extra = const <String>[],
  });

  final String? entry;
  final String? communion;
  final List<String> extra;
}

final class LiturgyDay {
  const LiturgyDay({
    required this.date,
    required this.title,
    required this.color,
    required this.prayers,
    required this.readings,
    required this.antiphons,
  });

  final DateTime date;
  final String title;
  final LiturgyColor color;
  final LiturgyPrayer prayers;
  final List<LiturgyReading> readings;
  final LiturgyAntiphons antiphons;
}
