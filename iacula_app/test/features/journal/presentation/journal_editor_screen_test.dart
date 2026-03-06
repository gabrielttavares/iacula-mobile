import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/journal/domain/entities/journal_entry.dart';
import 'package:iacula_app/features/journal/domain/repositories/journal_repository.dart';
import 'package:iacula_app/features/journal/presentation/journal_editor_screen.dart';
import 'package:iacula_app/features/journal_prompts/domain/entities/journal_prompt.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/prayer_activity/domain/entities/prayer_activity_entry.dart';
import 'package:iacula_app/features/prayer_activity/domain/repositories/prayer_activity_repository.dart';

final class _FakeJournalRepository implements JournalRepository {
  JournalEntry? savedEntry;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<JournalEntry?> getById(String id) async => null;

  @override
  Future<List<JournalEntry>> listAll() async => const [];

  @override
  Future<void> save(JournalEntry entry) async {
    savedEntry = entry;
  }

  @override
  Future<List<JournalEntry>> search(String query) async => const [];
}

final class _FakePrayerActivityRepository implements PrayerActivityRepository {
  final List<PrayerActivityEntry> saved = [];

  @override
  Future<List<PrayerActivityEntry>> listAll() async => saved;

  @override
  Future<List<PrayerActivityEntry>> listByDateRange(
    DateTime start,
    DateTime end,
  ) async => saved;

  @override
  Future<Map<String, int>> minutesByDateRange(
    DateTime start,
    DateTime end,
  ) async => const {};

  @override
  Future<void> save(PrayerActivityEntry entry) async {
    saved.add(entry);
  }

  @override
  Future<int> totalMinutesForDate(DateTime date) async => 0;
}

void main() {
  testWidgets(
    'journal editor shows initial prompt and saves typed body unchanged',
    (tester) async {
      final journalRepository = _FakeJournalRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumStatusProvider.overrideWith((ref) {
              return Stream<PremiumStatus>.value(
                const PremiumStatus(isPremium: true),
              );
            }),
            journalRepositoryProvider.overrideWithValue(journalRepository),
            prayerActivityRepositoryProvider.overrideWithValue(
              _FakePrayerActivityRepository(),
            ),
          ],
          child: CupertinoApp(
            home: JournalEditorScreen(
              initialPrompt: const JournalPrompt(
                id: 'prompt-1',
                category: JournalPromptCategory.general,
                text: 'Que graças recebi hoje?',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Que graças recebi hoje?'), findsOneWidget);

      await tester.enterText(
        find.byType(CupertinoTextField).at(1),
        'Meu texto',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(journalRepository.savedEntry, isNotNull);
      expect(journalRepository.savedEntry!.body, 'Meu texto');
      expect(journalRepository.savedEntry!.title, isNull);
    },
  );
}
