class ExaminationReflectionItem {
  const ExaminationReflectionItem({
    required this.id,
    required this.sectionTitle,
    required this.text,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String sectionTitle;
  final String text;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExaminationReflectionItem copyWith({
    String? id,
    String? sectionTitle,
    String? text,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExaminationReflectionItem(
      id: id ?? this.id,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      text: text ?? this.text,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
