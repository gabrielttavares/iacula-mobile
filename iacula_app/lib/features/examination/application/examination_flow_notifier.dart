// lib/features/examination/application/examination_flow_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/data/examination_checklist.dart';

enum ExaminationStep { preparation, examination, review, confession }

class ExaminationFlowState {
  const ExaminationFlowState({
    this.step = ExaminationStep.preparation,
    this.currentSectionIndex = 0,
    this.checkedItems = const {},
    this.freeText = '',
    this.generatedConfession,
  });

  final ExaminationStep step;
  final int currentSectionIndex;
  /// Map<sectionIndex, Set<itemIndex>>
  final Map<int, Set<int>> checkedItems;
  final String freeText;
  final String? generatedConfession;

  int get totalChecked {
    int count = 0;
    for (final items in checkedItems.values) {
      count += items.length;
    }
    return count;
  }

  int get totalSections => kExaminationSections.length;

  ExaminationFlowState copyWith({
    ExaminationStep? step,
    int? currentSectionIndex,
    Map<int, Set<int>>? checkedItems,
    String? freeText,
    String? generatedConfession,
  }) {
    return ExaminationFlowState(
      step: step ?? this.step,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      checkedItems: checkedItems ?? this.checkedItems,
      freeText: freeText ?? this.freeText,
      generatedConfession: generatedConfession ?? this.generatedConfession,
    );
  }
}

class ExaminationFlowNotifier extends StateNotifier<ExaminationFlowState> {
  ExaminationFlowNotifier() : super(const ExaminationFlowState());

  void startExamination() {
    state = state.copyWith(step: ExaminationStep.examination);
  }

  void toggleItem(int sectionIndex, int itemIndex) {
    final updated = Map<int, Set<int>>.from(state.checkedItems);
    final sectionItems = Set<int>.from(updated[sectionIndex] ?? {});
    if (sectionItems.contains(itemIndex)) {
      sectionItems.remove(itemIndex);
    } else {
      sectionItems.add(itemIndex);
    }
    updated[sectionIndex] = sectionItems;
    state = state.copyWith(checkedItems: updated);
  }

  void goToSection(int index) {
    state = state.copyWith(currentSectionIndex: index);
  }

  void nextSection() {
    if (state.currentSectionIndex < state.totalSections - 1) {
      state = state.copyWith(
        currentSectionIndex: state.currentSectionIndex + 1,
      );
    }
  }

  void previousSection() {
    if (state.currentSectionIndex > 0) {
      state = state.copyWith(
        currentSectionIndex: state.currentSectionIndex - 1,
      );
    }
  }

  void updateFreeText(String text) {
    state = state.copyWith(freeText: text);
  }

  void goToReview() {
    state = state.copyWith(step: ExaminationStep.review);
  }

  void goBackToExamination() {
    state = state.copyWith(step: ExaminationStep.examination);
  }

  void generateConfession() {
    final buffer = StringBuffer();
    buffer.writeln('Padre, eu pequei contra Deus nas seguintes faltas:');
    buffer.writeln();

    for (final entry in state.checkedItems.entries) {
      final section = kExaminationSections[entry.key];
      for (final itemIndex in entry.value.toList()..sort()) {
        buffer.writeln('• ${section.items[itemIndex]}');
      }
    }

    if (state.freeText.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('• ${state.freeText.trim()}');
    }

    buffer.writeln();
    buffer.writeln('Por estes e todos os meus pecados, peço perdão.');

    state = state.copyWith(
      step: ExaminationStep.confession,
      generatedConfession: buffer.toString(),
    );
  }

  void clearAll() {
    state = const ExaminationFlowState();
  }
}

final examinationFlowProvider = StateNotifierProvider.autoDispose<
    ExaminationFlowNotifier, ExaminationFlowState>((ref) {
  return ExaminationFlowNotifier();
});
