final class ReadingPointModel {
  const ReadingPointModel({this.number, this.title, required this.paragraphs});

  final int? number;
  final String? title;
  final List<String> paragraphs;

  factory ReadingPointModel.fromJson(Map<String, dynamic> json) {
    final numberRaw = json['number'];
    final parsedNumber = switch (numberRaw) {
      int() => numberRaw,
      String() => int.tryParse(numberRaw),
      _ => null,
    };

    return ReadingPointModel(
      number: parsedNumber,
      title: (json['title'] as String?)?.trim(),
      paragraphs: (json['paragraphs'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
    );
  }
}
