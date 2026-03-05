import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/rosary_mystery_set.dart';

class RosarySessionState {
  const RosarySessionState({
    required this.currentMysterySet,
    required this.currentDecadeIndex,
    required this.currentBeadIndex,
    required this.completedDecades,
    required this.startTime,
  });

  factory RosarySessionState.initial(RosaryMysterySet mysterySet) {
    return RosarySessionState(
      currentMysterySet: mysterySet,
      currentDecadeIndex: 0,
      currentBeadIndex: 0,
      completedDecades: const <int>{},
      startTime: DateTime.now(),
    );
  }

  final RosaryMysterySet currentMysterySet;
  final int currentDecadeIndex;
  final int currentBeadIndex;
  final Set<int> completedDecades;
  final DateTime startTime;

  bool get isRosaryComplete =>
      completedDecades.length >= currentMysterySet.mysteries.length;

  RosarySessionState copyWith({
    RosaryMysterySet? currentMysterySet,
    int? currentDecadeIndex,
    int? currentBeadIndex,
    Set<int>? completedDecades,
    DateTime? startTime,
  }) {
    return RosarySessionState(
      currentMysterySet: currentMysterySet ?? this.currentMysterySet,
      currentDecadeIndex: currentDecadeIndex ?? this.currentDecadeIndex,
      currentBeadIndex: currentBeadIndex ?? this.currentBeadIndex,
      completedDecades: completedDecades ?? this.completedDecades,
      startTime: startTime ?? this.startTime,
    );
  }
}

class RosarySessionNotifier extends StateNotifier<RosarySessionState> {
  RosarySessionNotifier(RosaryMysterySet mysterySet)
    : super(RosarySessionState.initial(mysterySet));

  static const int beadsPerDecade = 13;

  void advanceBead() {
    final isLastBead = state.currentBeadIndex >= beadsPerDecade - 1;
    if (!isLastBead) {
      state = state.copyWith(currentBeadIndex: state.currentBeadIndex + 1);
      return;
    }

    final updatedCompleted = <int>{
      ...state.completedDecades,
      state.currentDecadeIndex,
    };

    final isLastDecade =
        state.currentDecadeIndex >=
        state.currentMysterySet.mysteries.length - 1;

    if (isLastDecade) {
      state = state.copyWith(completedDecades: updatedCompleted);
      return;
    }

    state = state.copyWith(
      completedDecades: updatedCompleted,
      currentDecadeIndex: state.currentDecadeIndex + 1,
      currentBeadIndex: 0,
    );
  }

  void selectMystery(int index) {
    if (index < 0 || index >= state.currentMysterySet.mysteries.length) {
      return;
    }

    state = state.copyWith(currentDecadeIndex: index, currentBeadIndex: 0);
  }

  void reset() {
    state = RosarySessionState.initial(state.currentMysterySet);
  }
}

final rosarySessionProvider = StateNotifierProvider.autoDispose
    .family<RosarySessionNotifier, RosarySessionState, RosaryMysterySet>((
      ref,
      mysterySet,
    ) {
      return RosarySessionNotifier(mysterySet);
    });
