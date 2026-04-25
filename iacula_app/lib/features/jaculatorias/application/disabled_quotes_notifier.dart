import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../quotes/domain/repositories/disabled_quotes_repository.dart';

class DisabledQuotesNotifier
    extends AsyncNotifier<Map<int, Set<int>>> {
  DisabledQuotesRepository get _repository =>
      ref.read(disabledQuotesRepositoryProvider);

  @override
  Future<Map<int, Set<int>>> build() async {
    return _repository.loadAllDisabled(season: 'ordinary');
  }

  Future<void> toggle({
    required int dayOfWeek,
    required int quoteIndex,
  }) async {
    await _repository.toggle(
      dayOfWeek: dayOfWeek,
      quoteIndex: quoteIndex,
      season: 'ordinary',
    );
    state = await AsyncValue.guard(
      () => _repository.loadAllDisabled(season: 'ordinary'),
    );

    try {
      final settings = await ref.read(getSettingsUseCaseProvider).call();
      final season = await ref
          .read(liturgicalSeasonServiceProvider)
          .getCurrentSeason();
      await ref.read(rebuildNotificationsUseCaseProvider).call(
        settings,
        isEasterSeason: season == LiturgicalSeason.easter,
        showImmediate: false,
      );
    } catch (_) {
      // Notification rebuild failure should not block the toggle
    }
  }

  bool isDisabled(int dayOfWeek, int quoteIndex) {
    return state.valueOrNull?[dayOfWeek]?.contains(quoteIndex) ?? false;
  }
}
