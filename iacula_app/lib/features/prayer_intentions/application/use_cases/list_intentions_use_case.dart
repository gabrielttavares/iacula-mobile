// lib/features/prayer_intentions/application/use_cases/list_intentions_use_case.dart

import 'dart:convert';

import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/entities/intention_schedule.dart';
import '../../domain/entities/prayer_intention.dart';

final class ListIntentionsUseCase {
  const ListIntentionsUseCase(this._repository);

  final SpiritualEntryRepository _repository;

  Future<List<PrayerIntention>> call({bool includeResponded = false}) async {
    final entries = await _repository.listLocal();
    final intentions = entries.map((e) {
      final schedule = _parseSchedule(e.scheduleJson);
      return PrayerIntention(
        id: e.id,
        title: e.title ?? '',
        description: e.body.isNotEmpty ? e.body : null,
        createdAt: e.createdAt,
        respondedAt: e.respondedAt,
        schedule: schedule,
      );
    }).toList();

    if (!includeResponded) {
      intentions.removeWhere((i) => i.isResponded);
    }

    intentions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return intentions;
  }

  static IntentionSchedule? _parseSchedule(String? scheduleJson) {
    if (scheduleJson == null || scheduleJson.isEmpty) return null;
    try {
      final map = jsonDecode(scheduleJson) as Map<String, dynamic>;

      // Handle legacy format: {"reminderTime": "09:00"}
      if (map.containsKey('reminderTime') && !map.containsKey('type')) {
        final reminderTime = map['reminderTime']?.toString();
        if (reminderTime != null && reminderTime.isNotEmpty) {
          return IntentionSchedule(
            type: IntentionScheduleType.daily,
            times: [reminderTime],
          );
        }
        return null;
      }

      // Handle new schedule format
      return IntentionSchedule.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
