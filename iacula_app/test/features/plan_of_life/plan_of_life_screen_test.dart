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
  _FakeSpiritualEntryRepository([List<SpiritualEntry>? seed])
    : _entries = [...?seed];

  final List<SpiritualEntry> _entries;

  @override
  SpiritualModule get module => SpiritualModule.planOfLife;

  @override
  Future<List<SpiritualEntry>> listDirty() async => const [];

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      List<SpiritualEntry>.from(_entries);

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {}

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {}

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      _entries[index] = entry;
    } else {
      _entries.add(entry);
    }
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    for (final entry in entries) {
      await saveLocal(entry);
    }
  }
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

  testWidgets('default item opens schedule-only edit via three-dot menu', (
    tester,
  ) async {
    final now = DateTime.now();
    final entryRepository = _FakeSpiritualEntryRepository([
      SpiritualEntry(
        id: 'default-item',
        module: SpiritualModule.planOfLife,
        title: 'Oferecimento de obras',
        body: '',
        scheduleJson:
            '{"time":"07:00","daysOfWeek":[],"notify":false,"isDefault":true}',
        createdAt: now,
        updatedAt: now,
        isDirty: true,
      ),
    ]);
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

    await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle).first);
    await tester.pumpAndSettle();

    expect(find.text('Horário (HH:MM)'), findsOneWidget);
    expect(find.text('Dias da semana:'), findsOneWidget);
    expect(find.text('Lembrete (Notificação)'), findsOneWidget);
    expect(find.text('Título'), findsNothing);
  });
}
