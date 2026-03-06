import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/journal/domain/repositories/journal_repository.dart';
import 'package:iacula_app/features/journal/domain/entities/journal_entry.dart';
import 'package:iacula_app/features/journal/presentation/journal_editor_screen.dart';
import 'package:iacula_app/features/journal_prompts/domain/entities/journal_prompt.dart';
import 'package:iacula_app/features/journal_prompts/domain/repositories/journal_prompt_repository.dart';
import 'package:iacula_app/features/leituras/presentation/pages/leituras_home_page.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/domain/repositories/meditation_catalog_repository.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_screen.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/bible/presentation/bible_books_screen.dart';

final class _FakeMeditationCatalogRepository
    implements MeditationCatalogRepository {
  @override
  Future<MeditationItem?> getById(String id) async =>
      (await listAll()).firstWhere((item) => item.id == id);

  @override
  Future<List<MeditationItem>> listAll() async {
    return [
      MeditationItem.fromJson({
        'id': 'med-1',
        'type': 'text',
        'title': 'Meditação do dia',
        'summary': 'Resumo',
        'categoryTags': ['espiritual'],
        'sourceName': 'Fonte',
        'availability': {'kind': 'evergreen'},
        'textContent': {'body': 'Corpo', 'format': 'plain', 'language': 'pt'},
        'provenance': {'providerId': 'test', 'providerType': 'channel'},
      }),
      MeditationItem.fromJson({
        'id': 'med-2',
        'type': 'text',
        'title': 'Evangelho',
        'summary': 'Outro resumo',
        'categoryTags': ['evangelho'],
        'sourceName': 'Fonte',
        'availability': {'kind': 'evergreen'},
        'textContent': {
          'body': 'Outro corpo',
          'format': 'plain',
          'language': 'pt',
        },
        'provenance': {'providerId': 'test', 'providerType': 'channel'},
      }),
    ];
  }

  @override
  Future<List<MeditationItem>> listByCategory(String category) async => [];

  @override
  Future<List<MeditationItem>> listByType(MeditationType type) async => [];
}

final class _FakeJournalPromptRepository implements JournalPromptRepository {
  @override
  Future<List<JournalPrompt>> listAll() async {
    return const [
      JournalPrompt(
        id: 'prompt-1',
        category: JournalPromptCategory.ignatian,
        text: 'Pelo que sou grato a Deus hoje?',
      ),
    ];
  }
}

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

void main() {
  testWidgets('meditation screen shows prompt filter and opens journal flow', (
    tester,
  ) async {
    final journalRepository = _FakeJournalRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          meditationCatalogRepositoryProvider.overrideWithValue(
            _FakeMeditationCatalogRepository(),
          ),
          journalPromptRepositoryProvider.overrideWithValue(
            _FakeJournalPromptRepository(),
          ),
          journalRepositoryProvider.overrideWithValue(journalRepository),
        ],
        child: const CupertinoApp(home: MeditationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reflexão guiada'), findsOneWidget);

    await tester.tap(find.text('Reflexão guiada'));
    await tester.pumpAndSettle();

    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);

    await tester.tap(find.text('Pelo que sou grato a Deus hoje?'));
    await tester.pumpAndSettle();

    expect(find.text('Escrever no diário'), findsOneWidget);

    await tester.tap(find.text('Escrever no diário'));
    await tester.pumpAndSettle();

    expect(find.byType(JournalEditorScreen), findsOneWidget);
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);
  });

  testWidgets('prompt detail shortcuts open Leituras and Bíblia', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          meditationCatalogRepositoryProvider.overrideWithValue(
            _FakeMeditationCatalogRepository(),
          ),
          journalPromptRepositoryProvider.overrideWithValue(
            _FakeJournalPromptRepository(),
          ),
        ],
        child: const CupertinoApp(home: MeditationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reflexão guiada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelo que sou grato a Deus hoje?'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abrir Leituras'));
    await tester.pumpAndSettle();
    expect(find.byType(LeiturasHomePage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abrir Bíblia'));
    await tester.pumpAndSettle();
    expect(find.byType(BibleBooksScreen), findsOneWidget);
  });

  testWidgets('existing meditation filters do not show prompt cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          meditationCatalogRepositoryProvider.overrideWithValue(
            _FakeMeditationCatalogRepository(),
          ),
          journalPromptRepositoryProvider.overrideWithValue(
            _FakeJournalPromptRepository(),
          ),
        ],
        child: const CupertinoApp(home: MeditationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);

    await tester.tap(find.text('Espiritual'));
    await tester.pumpAndSettle();
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsNothing);
    expect(find.text('Meditação do dia'), findsOneWidget);

    await tester.tap(find.text('Reflexão guiada'));
    await tester.pumpAndSettle();
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);
    expect(find.text('Meditação do dia'), findsNothing);
  });
}
