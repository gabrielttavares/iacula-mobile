import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/plan_of_life/application/plan_of_life_notifier.dart';
import 'package:iacula_app/features/plan_of_life/application/use_cases/add_plan_item_use_case.dart';
import 'package:iacula_app/features/plan_of_life/application/use_cases/delete_plan_item_use_case.dart';
import 'package:iacula_app/features/plan_of_life/application/use_cases/get_daily_plan_use_case.dart';
import 'package:iacula_app/features/plan_of_life/application/use_cases/toggle_item_use_case.dart';
import 'package:iacula_app/features/plan_of_life/application/use_cases/update_plan_item_use_case.dart';
import 'package:iacula_app/features/plan_of_life/domain/entities/daily_completion.dart';
import 'package:iacula_app/features/plan_of_life/domain/repositories/plan_completion_repository.dart';
import 'package:iacula_app/features/plan_of_life/presentation/plan_of_life_screen.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _FakeSpiritualEntryRepository implements SpiritualEntryRepository {
  @override
  SpiritualModule get module => SpiritualModule.planOfLife;

  @override
  Future<List<SpiritualEntry>> listDirty() async => const [];

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      const [];

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {}

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {}

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {}

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {}
}

final class _FakePlanCompletionRepository implements PlanCompletionRepository {
  @override
  Future<void> deleteCompletion(String itemId, String date) async {}

  @override
  Future<List<DailyCompletion>> getCompletionsForDate(String date) async =>
      const [];

  @override
  Future<void> saveCompletion(DailyCompletion completion) async {}
}

void main() {
  testWidgets('date strip highlights the real selected date', (tester) async {
    final entryRepository = _FakeSpiritualEntryRepository();
    final completionRepository = _FakePlanCompletionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith(
            (ref) => Stream.value(const PremiumStatus(isPremium: true)),
          ),
          planOfLifeNotifierProvider.overrideWith(
            (ref) => PlanOfLifeNotifier(
              getDailyPlan: GetDailyPlanUseCase(
                entryRepository,
                completionRepository,
              ),
              toggleItem: ToggleItemUseCase(completionRepository),
              addItem: AddPlanItemUseCase(entryRepository),
              updateItem: UpdatePlanItemUseCase(entryRepository),
              deleteItem: DeletePlanItemUseCase(entryRepository),
            ),
          ),
        ],
        child: const CupertinoApp(home: PlanOfLifeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final targetDate = DateTime.now().subtract(const Duration(days: 3));
    final targetDay = targetDate.day.toString().padLeft(2, '0');

    await tester.tap(find.text(targetDay).first);
    await tester.pumpAndSettle();

    final selectedText = tester.widget<Text>(find.text(targetDay).first);
    expect(selectedText.style?.fontWeight, FontWeight.bold);
  });
}
