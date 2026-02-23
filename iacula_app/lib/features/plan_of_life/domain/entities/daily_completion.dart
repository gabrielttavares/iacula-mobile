class DailyCompletion {
  const DailyCompletion({
    required this.itemId,
    required this.date,
    required this.completedAt,
  });

  final String itemId;
  final String date; // format: "YYYY-MM-DD"
  final DateTime completedAt;
  
  String get id => '${itemId}_$date';
}
