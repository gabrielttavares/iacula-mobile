import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/plan_item.dart';
import '../domain/entities/plan_item_schedule.dart';
import 'use_cases/add_plan_item_use_case.dart';
import 'use_cases/delete_plan_item_use_case.dart';
import 'use_cases/get_daily_plan_use_case.dart';
import 'use_cases/toggle_item_use_case.dart';
import 'use_cases/update_plan_item_use_case.dart';

class PlanOfLifeState {
  const PlanOfLifeState({
    required this.selectedDate,
    this.items = const [],
    this.isLoading = false,
  });

  final DateTime selectedDate;
  final List<PlanItem> items;
  final bool isLoading;

  PlanOfLifeState copyWith({
    DateTime? selectedDate,
    List<PlanItem>? items,
    bool? isLoading,
  }) {
    return PlanOfLifeState(
      selectedDate: selectedDate ?? this.selectedDate,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PlanOfLifeNotifier extends StateNotifier<PlanOfLifeState> {
  PlanOfLifeNotifier({
    required GetDailyPlanUseCase getDailyPlan,
    required ToggleItemUseCase toggleItem,
    required AddPlanItemUseCase addItem,
    required UpdatePlanItemUseCase updateItem,
    required DeletePlanItemUseCase deleteItem,
  })  : _getDailyPlan = getDailyPlan,
        _toggleItem = toggleItem,
        _addItem = addItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        super(PlanOfLifeState(selectedDate: DateTime.now())) {
    _loadData();
  }

  final GetDailyPlanUseCase _getDailyPlan;
  final ToggleItemUseCase _toggleItem;
  final AddPlanItemUseCase _addItem;
  final UpdatePlanItemUseCase _updateItem;
  final DeletePlanItemUseCase _deleteItem;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    final items = await _getDailyPlan(state.selectedDate);
    if (!mounted) return;
    state = state.copyWith(items: items, isLoading: false);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    _loadData();
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    // Optimistic update
    final currentItems = List<PlanItem>.from(state.items);
    final index = currentItems.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final item = currentItems[index];
      currentItems[index] = item.copyWith(
        completedAt: completed ? DateTime.now() : null,
        clearCompletedAt: !completed,
      );
      state = state.copyWith(items: currentItems);
    }

    try {
      await _toggleItem(
        itemId: itemId,
        date: state.selectedDate,
        completed: completed,
      );
    } catch (_) {
      // Revert on error
      _loadData();
    }
  }

  Future<void> addItem(String title, PlanItemSchedule schedule) async {
    await _addItem(title: title, schedule: schedule);
    await _loadData();
  }

  Future<void> updateItem(String itemId, String title, PlanItemSchedule schedule) async {
    await _updateItem(itemId: itemId, title: title, schedule: schedule);
    await _loadData();
  }

  Future<void> deleteItem(String itemId) async {
    await _deleteItem(itemId);
    await _loadData();
  }
}
