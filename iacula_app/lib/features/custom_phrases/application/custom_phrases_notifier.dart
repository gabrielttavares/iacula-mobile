import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/custom_phrase.dart';
import '../domain/repositories/custom_phrase_repository.dart';
import 'use_cases/schedule_phrase_notifications_use_case.dart';

class CustomPhrasesNotifier extends AsyncNotifier<List<CustomPhrase>> {
  CustomPhraseRepository get _repository => ref.read(customPhraseRepositoryProvider);
  SchedulePhraseNotificationsUseCase get _scheduleUseCase =>
      ref.read(schedulePhraseNotificationsUseCaseProvider);

  @override
  Future<List<CustomPhrase>> build() async {
    return _repository.listAll();
  }

  Future<void> save(CustomPhrase phrase) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = phrase.copyWith(updatedAt: DateTime.now());
      await _repository.save(updated);
      await _scheduleUseCase(phraseId: phrase.id);
      return _repository.listAll();
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.delete(id);
      await _scheduleUseCase(phraseId: id); // Use case handles cancellation
      return _repository.listAll();
    });
  }

  Future<void> toggleActive(String id) async {
    final current = state.valueOrNull?.firstWhere((p) => p.id == id);
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = current.copyWith(
        isActive: !current.isActive,
        updatedAt: DateTime.now(),
      );
      await _repository.save(updated);
      await _scheduleUseCase(phraseId: id);
      return _repository.listAll();
    });
  }
}
