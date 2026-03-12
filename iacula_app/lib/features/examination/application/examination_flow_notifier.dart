// lib/features/examination/application/examination_flow_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../confession/domain/entities/confession_examination_item.dart';

enum ExaminationStep { preparation, examination }

class ExaminationFlowState {
  const ExaminationFlowState({
    this.step = ExaminationStep.preparation,
    this.selectedItemIds = const <String>{},
  });

  final ExaminationStep step;
  final Set<String> selectedItemIds;

  int get totalChecked => selectedItemIds.length;

  ExaminationFlowState copyWith({
    ExaminationStep? step,
    Set<String>? selectedItemIds,
  }) {
    return ExaminationFlowState(
      step: step ?? this.step,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

class ExaminationFlowNotifier extends StateNotifier<ExaminationFlowState> {
  ExaminationFlowNotifier() : super(const ExaminationFlowState());

  void startExamination() {
    state = state.copyWith(step: ExaminationStep.examination);
  }

  void toggleItem(String itemId) {
    final updated = Set<String>.from(state.selectedItemIds);
    if (updated.contains(itemId)) {
      updated.remove(itemId);
    } else {
      updated.add(itemId);
    }
    state = state.copyWith(selectedItemIds: updated);
  }

  String buildShareText(List<ConfessionExaminationItem> items) {
    return items
        .where((item) => state.selectedItemIds.contains(item.id))
        .map((item) => item.text)
        .join('\n');
  }

  void clearAll() {
    state = const ExaminationFlowState();
  }
}

final examinationFlowProvider =
    StateNotifierProvider.autoDispose<
      ExaminationFlowNotifier,
      ExaminationFlowState
    >((ref) {
      return ExaminationFlowNotifier();
    });
