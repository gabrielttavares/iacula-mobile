final class ConfessionExaminationItem {
  const ConfessionExaminationItem({
    required this.id,
    required this.text,
    required this.sortOrder,
  });

  final String id;
  final String text;
  final int sortOrder;

  factory ConfessionExaminationItem.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final text = json['text']?.toString().trim() ?? '';
    final sortOrder = (json['sort_order'] as num?)?.toInt() ?? 0;

    if (id.isEmpty || text.isEmpty) {
      throw const FormatException('Invalid confession examination item.');
    }

    return ConfessionExaminationItem(id: id, text: text, sortOrder: sortOrder);
  }
}
