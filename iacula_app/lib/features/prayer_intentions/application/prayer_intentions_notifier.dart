// lib/features/prayer_intentions/application/prayer_intentions_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/prayer_intention.dart';
import 'use_cases/add_intention_use_case.dart';
import 'use_cases/cancel_prayer_intention_reminder_use_case.dart';
import 'use_cases/delete_intention_use_case.dart';
import 'use_cases/list_intentions_use_case.dart';
import 'use_cases/respond_intention_use_case.dart';
import 'use_cases/schedule_prayer_intention_reminder_use_case.dart';
import 'use_cases/update_intention_use_case.dart';

class PrayerIntentionsState {
  const PrayerIntentionsState({
    this.openIntentions = const [],
    this.respondedIntentions = const [],
    this.isLoading = false,
  });

  final List<PrayerIntention> openIntentions;
  final List<PrayerIntention> respondedIntentions;
  final bool isLoading;

  PrayerIntentionsState copyWith({
    List<PrayerIntention>? openIntentions,
    List<PrayerIntention>? respondedIntentions,
    bool? isLoading,
  }) {
    return PrayerIntentionsState(
      openIntentions: openIntentions ?? this.openIntentions,
      respondedIntentions: respondedIntentions ?? this.respondedIntentions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrayerIntentionsNotifier extends StateNotifier<PrayerIntentionsState> {
  PrayerIntentionsNotifier({
    required ListIntentionsUseCase listIntentions,
    required AddIntentionUseCase addIntention,
    required UpdateIntentionUseCase updateIntention,
    required DeleteIntentionUseCase deleteIntention,
    required RespondIntentionUseCase respondIntention,
    required SchedulePrayerIntentionReminderUseCase scheduleReminder,
    required CancelPrayerIntentionReminderUseCase cancelReminder,
  })  : _listIntentions = listIntentions,
        _addIntention = addIntention,
        _updateIntention = updateIntention,
        _deleteIntention = deleteIntention,
        _respondIntention = respondIntention,
        _scheduleReminder = scheduleReminder,
        _cancelReminder = cancelReminder,
        super(const PrayerIntentionsState()) {
    loadData();
  }

  final ListIntentionsUseCase _listIntentions;
  final AddIntentionUseCase _addIntention;
  final UpdateIntentionUseCase _updateIntention;
  final DeleteIntentionUseCase _deleteIntention;
  final RespondIntentionUseCase _respondIntention;
  final SchedulePrayerIntentionReminderUseCase _scheduleReminder;
  final CancelPrayerIntentionReminderUseCase _cancelReminder;

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final open = await _listIntentions(includeResponded: false);
    final all = await _listIntentions(includeResponded: true);
    final responded = all.where((i) => i.isResponded).toList();
    if (!mounted) return;
    state = state.copyWith(
      openIntentions: open,
      respondedIntentions: responded,
      isLoading: false,
    );
  }

  Future<void> addIntention({required String title, String? description}) async {
    await _addIntention(title: title, description: description);
    await loadData();
  }

  Future<void> updateIntention({
    required String id,
    required String title,
    String? description,
  }) async {
    await _updateIntention(id: id, title: title, description: description);
    await loadData();
  }

  Future<void> deleteIntention(String id) async {
    await _deleteIntention(id);
    await loadData();
  }

  Future<void> markResponded(String id) async {
    await _respondIntention(id);
    await loadData();
  }

  Future<void> setReminder(String intentionId, String hhmm) async {
    await _scheduleReminder(intentionId, hhmm);
    await loadData();
  }

  Future<void> clearReminder(String intentionId) async {
    await _cancelReminder(intentionId);
    await loadData();
  }
}
