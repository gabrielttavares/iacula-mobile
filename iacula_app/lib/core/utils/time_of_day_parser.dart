class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute});
  final int hour;
  final int minute;

  @override
  String toString() => '$hour:$minute';
}

TimeOfDay parseHourMinute(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    throw FormatException('Expected HH:MM, got: $value');
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    throw FormatException('Expected numeric HH:MM, got: $value');
  }

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw FormatException('Hour/minute out of range: $value');
  }

  return TimeOfDay(hour: hour, minute: minute);
}
