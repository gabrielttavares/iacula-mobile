import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import 'plan_item_schedule.dart';

class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.schedule,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final PlanItemSchedule schedule;
  final DateTime createdAt;
  
  // Ephemeral property used when loaded with a specific date
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  factory PlanItem.fromSpiritualEntry(SpiritualEntry entry, {DateTime? completedAt}) {
    PlanItemSchedule schedule;
    try {
      schedule = entry.scheduleJson != null
          ? PlanItemSchedule.fromJson(entry.scheduleJson!)
          : const PlanItemSchedule(daysOfWeek: [], notify: false);
    } catch (_) {
      schedule = const PlanItemSchedule(daysOfWeek: [], notify: false);
    }

    return PlanItem(
      id: entry.id,
      title: entry.title ?? '',
      schedule: schedule,
      createdAt: entry.createdAt,
      completedAt: completedAt,
    );
  }

  PlanItem copyWith({
    String? id,
    String? title,
    PlanItemSchedule? schedule,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return PlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
}
