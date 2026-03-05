import 'chapter_model.dart';

final class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.type,
    required this.assetPath,
    required this.description,
    required this.chapters,
  });

  final String id;
  final String title;
  final String author;
  final String type;
  final String assetPath;
  final String description;
  final List<ChapterModel> chapters;

  factory BookModel.fromIndexJson(Map<String, dynamic> json) {
    return BookModel(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      author: (json['author'] as String? ?? '').trim(),
      type: (json['type'] as String? ?? 'points').trim(),
      assetPath: (json['assetPath'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      chapters: (json['chapters'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ChapterModel.fromIndexJson)
          .toList(growable: false),
    );
  }

  BookModel copyWith({List<ChapterModel>? chapters}) {
    return BookModel(
      id: id,
      title: title,
      author: author,
      type: type,
      assetPath: assetPath,
      description: description,
      chapters: chapters ?? this.chapters,
    );
  }
}
