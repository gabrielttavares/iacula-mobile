import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/widgets/iacula_horizontal_card_rail.dart';
import 'package:iacula_app/features/challenges/presentation/challenge_library_screen.dart';
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
      JournalPrompt(
        id: 'prompt-2',
        category: JournalPromptCategory.lectioDivina,
        text: 'Que palavra Deus me dirige através desta leitura?',
      ),
      JournalPrompt(
        id: 'prompt-3',
        category: JournalPromptCategory.liturgical,
        text: 'Como a leitura de hoje fala à minha vida?',
      ),
      JournalPrompt(
        id: 'prompt-4',
        category: JournalPromptCategory.general,
        text: 'Que graças recebi hoje?',
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

Widget _buildMeditationTestApp({
  JournalRepository? journalRepository,
  DateTime Function()? now,
}) {
  return ProviderScope(
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
      if (journalRepository != null)
        journalRepositoryProvider.overrideWithValue(journalRepository),
    ],
    child: CupertinoApp(home: MeditationScreen(now: now)),
  );
}

void main() {
  testWidgets(
    'meditation screen shows grouped Reflexões card and opens journal flow',
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

      expect(find.text('Reflexões'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('meditation-resource-icon-reflexoes')),
        findsOneWidget,
      );
      expect(find.text('Lectio Divina'), findsOneWidget);
      expect(find.text('Inaciano'), findsOneWidget);
      expect(find.text('Litúrgico'), findsOneWidget);
      expect(find.text('Geral'), findsOneWidget);
      expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);

      await tester.tap(find.text('Pelo que sou grato a Deus hoje?'));
      await tester.pumpAndSettle();

      expect(find.text('Escrever no diário'), findsOneWidget);

      await tester.tap(find.text('Escrever no diário'));
      await tester.pumpAndSettle();

      expect(find.byType(JournalEditorScreen), findsOneWidget);
      expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);
    },
  );

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
    await tester.pumpWidget(_buildMeditationTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Reflexões'), findsOneWidget);
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);

    await tester.tap(find.text('Espiritual'));
    await tester.pumpAndSettle();
    expect(find.text('Reflexões'), findsNothing);
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsNothing);
    expect(find.text('Meditação do dia'), findsOneWidget);

    await tester.ensureVisible(find.text('Reflexão guiada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reflexão guiada'));
    await tester.pumpAndSettle();
    expect(find.text('Reflexões'), findsOneWidget);
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsOneWidget);
    expect(find.text('Meditação do dia'), findsNothing);
  });

  testWidgets('meditation screen shows March novenas rail with dates', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(now: () => DateTime(2026, 3, 6)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Novenas do mês'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Novenas do mês'), findsOneWidget);
    expect(find.text('Novena a São Patrício'), findsOneWidget);
    expect(find.text('8 a 16 de março'), findsOneWidget);
    expect(find.text('Novena a São José'), findsOneWidget);
    expect(find.text('10 a 18 de março'), findsOneWidget);
    expect(find.text('Ver todas'), findsOneWidget);

    await tester.drag(
      find.byType(IaculaHorizontalCardRail),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Novena da Anunciação'), findsOneWidget);
    expect(find.text('16 a 24 de março'), findsOneWidget);
  });

  testWidgets('tapping ver todas opens challenge library screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(now: () => DateTime(2026, 3, 6)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Ver todas'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();

    expect(find.byType(ChallengeLibraryScreen), findsOneWidget);
  });
}
