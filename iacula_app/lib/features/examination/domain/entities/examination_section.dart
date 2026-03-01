// lib/features/examination/domain/entities/examination_section.dart

final class ExaminationSection {
  const ExaminationSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}
