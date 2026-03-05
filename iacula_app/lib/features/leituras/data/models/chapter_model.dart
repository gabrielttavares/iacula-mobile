import 'reading_point_model.dart';

final class ChapterModel {
  const ChapterModel({
    required this.slug,
    required this.title,
    required this.kind,
    required this.sections,
    required this.paragraphs,
  });

  final String slug;
  final String title;
  final String kind;
  final List<ReadingPointModel> sections;
  final List<String> paragraphs;

  factory ChapterModel.fromIndexJson(Map<String, dynamic> json) {
    return ChapterModel(
      slug: (json['slug'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      kind: (json['kind'] as String? ?? 'points').trim(),
      sections: const <ReadingPointModel>[],
      paragraphs: const <String>[],
    );
  }

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final introParagraphs =
        (json['paragraphs'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);

    final sectionList =
        (json['sections'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ReadingPointModel.fromJson)
            .toList(growable: false);

    final numberedSections =
        (json['numberedSections'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ReadingPointModel.fromJson)
            .toList(growable: false);

    return ChapterModel(
      slug: (json['slug'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      kind: (json['kind'] as String? ?? 'points').trim(),
      sections: sectionList.isNotEmpty ? sectionList : numberedSections,
      paragraphs: introParagraphs,
    );
  }
}
