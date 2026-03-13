import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/examination/domain/entities/examination_reflection_item.dart';
import 'package:iacula_app/features/examination/domain/repositories/examination_reflection_repository.dart';
import 'package:iacula_app/features/examination/presentation/examination_reading_screen.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/presentation/liturgia_screen.dart';
import 'package:iacula_app/core/presentation/widgets/premium_touchable_card.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/leituras/presentation/pages/leituras_home_page.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_catalog_group_screen.dart';
import 'package:iacula_app/features/challenges/domain/entities/challenge.dart';
import 'package:iacula_app/features/challenges/domain/entities/challenge_progress.dart';
import 'package:iacula_app/features/challenges/domain/repositories/challenge_progress_repository.dart';
import 'package:iacula_app/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:iacula_app/features/challenges/presentation/challenge_library_screen.dart';
import 'package:iacula_app/features/challenges/presentation/challenge_detail_screen.dart';
import 'package:iacula_app/features/bible/presentation/bible_books_screen.dart';
import 'package:iacula_app/features/rosary/presentation/rosary_intro_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.value);

  Settings value;

  @override
  Future<Settings> load() async => value;

  @override
  Future<void> save(Settings settings) async {
    value = settings;
  }
}

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this.value);

  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

final class _ThrowingLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  @override
  Future<LastDeliveredCard?> load() async {
    throw StateError('load failed');
  }

  @override
  Future<void> save(LastDeliveredCard card) async {}
}

final class _FakeLiturgiaRepository implements LiturgiaRepository {
  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async => null;

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int days) async {
    return [
      LiturgyDay(
        date: DateTime(2026, 2, 22),
        title: 'Domingo',
        color: LiturgyColor.green,
        prayers: const LiturgyPrayer(
          collect: 'Coleta',
          offering: 'Oferendas',
          communion: 'Comunhao',
        ),
        readings: const [
          LiturgyReading(reference: 'Ref', title: 'Leitura', text: 'Texto'),
        ],
        antiphons: const LiturgyAntiphons(entry: 'Antifona'),
      ),
    ];
  }
}

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return const <PrayerCatalogEntry>[
      PrayerCatalogEntry(
        slug: 'salve-rainha',
        title: 'Salve Rainha',
        content: 'Texto',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
      PrayerCatalogEntry(
        slug: 'ave-maria',
        title: 'Ave Maria',
        content: 'Texto',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
      PrayerCatalogEntry(
        slug: 'anjo-da-guarda',
        title: 'Ao Anjo da Guarda',
        content: 'Texto',
        themes: ['protecao'],
        saints: ['anjos'],
      ),
      PrayerCatalogEntry(
        slug: 'sao-jose-operario',
        title: 'São José Operário',
        content: 'Texto',
        themes: ['trabalho'],
        saints: ['sao-jose'],
      ),
    ];
  }
}

final class _RankingPrayerCatalogRepository implements PrayerCatalogRepository {
  const _RankingPrayerCatalogRepository();

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return const <PrayerCatalogEntry>[
      PrayerCatalogEntry(
        slug: 'familia-1',
        title: 'Família',
        content: 'Texto',
        themes: ['familia'],
        saints: [],
      ),
      PrayerCatalogEntry(
        slug: 'igreja-1',
        title: 'Igreja',
        content: 'Texto',
        themes: ['igreja'],
        saints: [],
      ),
      PrayerCatalogEntry(
        slug: 'trabalho-1',
        title: 'Trabalho',
        content: 'Texto',
        themes: ['trabalho'],
        saints: [],
      ),
      PrayerCatalogEntry(
        slug: 'eucaristica-1',
        title: 'Eucarística',
        content: 'Texto',
        themes: ['eucaristica'],
        saints: [],
      ),
    ];
  }
}

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  const _FakeLiturgicalSeasonService(this.context);

  final LiturgicalContext context;

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    return context.season;
  }

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    return context;
  }
}

final class _FakeChallengeRepository implements ChallengeRepository {
  const _FakeChallengeRepository();

  @override
  Future<Challenge?> getById(String id) async {
    return _challenges.where((challenge) => challenge.id == id).firstOrNull;
  }

  @override
  Future<List<Challenge>> listAll() async => _challenges;
}

final class _FakeChallengeProgressRepository
    implements ChallengeProgressRepository {
  const _FakeChallengeProgressRepository();

  @override
  Future<void> deleteProgress(String challengeId) async {}

  @override
  Future<ChallengeProgress?> getProgress(String challengeId) async => null;

  @override
  Future<List<ChallengeProgress>> listActive() async => const [];

  @override
  Future<void> saveProgress(ChallengeProgress progress) async {}
}

final class _FakeExaminationReflectionRepository
    implements ExaminationReflectionRepository {
  _FakeExaminationReflectionRepository([List<ExaminationReflectionItem>? seed])
    : _items = [...?seed];

  final List<ExaminationReflectionItem> _items;

  @override
  Future<void> createItem({
    required String sectionTitle,
    required String text,
  }) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<ExaminationReflectionItem>> listAll() async =>
      List<ExaminationReflectionItem>.from(_items);

  @override
  Future<void> seedDefaultsIfEmpty() async {}

  @override
  Future<void> updateItem(ExaminationReflectionItem item) async {}

  @override
  Stream<List<ExaminationReflectionItem>> watchAll() async* {
    yield await listAll();
  }
}

const _challenges = <Challenge>[
  Challenge(
    id: 'novena_sao_patricio',
    title: 'Novena a São Patrício',
    description: 'Descrição São Patrício',
    durationDays: 9,
    category: ChallengeCategory.novena,
    content: [
      ChallengeDay(
        dayNumber: 1,
        title: 'Primeiro Dia',
        readingText: 'Texto São Patrício',
        reflectionPrompt: 'Reflexão São Patrício',
      ),
    ],
  ),
  Challenge(
    id: 'novena_sao_jose',
    title: 'Novena a São José',
    description: 'Descrição São José',
    durationDays: 9,
    category: ChallengeCategory.novena,
    content: [
      ChallengeDay(
        dayNumber: 1,
        title: 'São José, Pai Nutrício de Jesus',
        readingText: 'Conteúdo de São José',
        reflectionPrompt: 'Reflexão São José',
      ),
    ],
  ),
];

Widget _buildApp({
  required _FakeSettingsRepository settingsRepo,
  required _FakeLastDeliveredCardRepository lastCardRepo,
  _FakeLiturgiaRepository? liturgiaRepo,
  PrayerCatalogRepository? prayerCatalogRepo,
  ChallengeRepository challengeRepository = _defaultChallengeRepo,
  ChallengeProgressRepository challengeProgressRepository =
      _defaultChallengeProgressRepo,
  LiturgicalSeasonService? liturgicalSeasonService,
  ExaminationReflectionRepository? examinationReflectionRepository,
  DateTime? now,
  Map<String, WidgetBuilder>? routes,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      lastDeliveredCardRepositoryProvider.overrideWithValue(lastCardRepo),
      if (liturgiaRepo != null)
        liturgiaCacheRepositoryProvider.overrideWithValue(liturgiaRepo),
      if (prayerCatalogRepo != null)
        prayerCatalogRepositoryProvider.overrideWithValue(prayerCatalogRepo),
      challengeRepositoryProvider.overrideWithValue(challengeRepository),
      challengeProgressRepositoryProvider.overrideWithValue(
        challengeProgressRepository,
      ),
      if (liturgicalSeasonService != null)
        liturgicalSeasonServiceProvider.overrideWithValue(
          liturgicalSeasonService,
        ),
      if (examinationReflectionRepository != null)
        examinationReflectionRepositoryProvider.overrideWithValue(
          examinationReflectionRepository,
        ),
      if (now != null) homeNowProvider.overrideWithValue(now),
    ],
    child: CupertinoApp(routes: routes ?? const {}, home: const HomeScreen()),
  );
}

_FakeSettingsRepository _defaultSettingsRepo() =>
    _FakeSettingsRepository(Settings.defaults);

_FakeLastDeliveredCardRepository _defaultLastCardRepo() =>
    _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: 'Permanecei em mim.',
        theme: 'Conversao',
        season: 'lent',
        deliveredAt: DateTime(2026, 2, 21, 11, 0),
      ),
    );

const _defaultChallengeRepo = _FakeChallengeRepository();
const _defaultChallengeProgressRepo = _FakeChallengeProgressRepository();

void main() {
  testWidgets('home hero keeps long quote visible without truncation', (
    tester,
  ) async {
    const longQuote =
        'LONG_QUOTE_MARKER Permanecei em mim, e Eu permanecerei em vos. Assim como o ramo nao pode dar fruto por si mesmo, se nao permanecer na videira, assim tambem vos, se nao permanecerdes em mim. '; // cspell:disable-line
    final lastCardRepo = _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: longQuote + longQuote,
        theme: 'Conversao',
        season: 'lent',
        deliveredAt: DateTime(2026, 2, 21, 11, 0),
      ),
    );

    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: lastCardRepo,
      ),
    );
    await tester.pumpAndSettle();

    final quoteFinder = find.textContaining('LONG_QUOTE_MARKER');
    for (var i = 0; i < 20 && quoteFinder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pumpAndSettle();
    }

    expect(quoteFinder, findsOneWidget);

    final quoteText = tester.widget<Text>(quoteFinder);
    expect(quoteText.maxLines, isNull);
    expect(quoteText.overflow, isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);

    await tester.tap(find.byKey(const Key('home_hero_card')));
    await tester.pumpAndSettle();
    expect(find.text('Os cards e o tempo litúrgico'), findsOneWidget);
    expect(find.text('O que torna o Iacula único'), findsOneWidget);
  });

  testWidgets('home hero uses Escriva source when feed toggle is enabled', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository(
      Settings.defaults.copyWith(escrivaPointsFeedEnabled: true),
    );
    final lastCardRepo = _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: 'SHOULD_NOT_RENDER',
        theme: 'Conversao',
        season: 'lent',
        deliveredAt: DateTime(2026, 2, 21, 11, 0),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          lastDeliveredCardRepositoryProvider.overrideWithValue(lastCardRepo),
          leituraRepositoryProvider.overrideWithValue(
            LeituraRepository(
              localSource: LeituraLocalSource(
                loadAsset: (path) async {
                  if (path.endsWith('index.json')) {
                    return jsonEncode({
                      'books': [
                        {
                          'id': 'caminho',
                          'title': 'Caminho',
                          'author': 'Autor',
                          'description': 'x',
                          'type': 'points',
                          'assetPath': 'assets/books/escriva/caminho.json',
                        },
                      ],
                    });
                  }

                  return jsonEncode({
                    'chapters': [
                      {
                        'slug': 'carater',
                        'title': 'Caráter',
                        'kind': 'points',
                        'sections': [
                          {
                            'number': 1,
                            'paragraphs': ['ESCRIVA_HERO_MARKER'],
                          },
                        ],
                      },
                    ],
                  });
                },
              ),
            ),
          ),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ESCRIVA_HERO_MARKER'), findsOneWidget);
    expect(find.textContaining('SHOULD_NOT_RENDER'), findsNothing);
    expect(find.text('caminho, 1'), findsOneWidget);
    expect(find.text('tempo comum'), findsNothing);
  });

  testWidgets('home follows required section order', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        examinationReflectionRepository: _FakeExaminationReflectionRepository([
          ExaminationReflectionItem(
            id: '1',
            sectionTitle: 'Acto de Presença de Deus',
            text: 'Meu Deus, dai-me luz para conhecer os pecados.',
            sortOrder: 0,
            createdAt: DateTime(2026, 3, 11),
            updatedAt: DateTime(2026, 3, 11),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> reveal(String text) async {
      final finder = find.text(text);
      for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(finder, findsOneWidget);
    }

    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    await reveal('Minhas frases');
    await reveal('Ação de Graças');
    await reveal('Bíblia');
  });

  testWidgets('home renders hero card before quick actions', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
    expect(find.byKey(const Key('home_shortcuts_rail')), findsOneWidget);
  });

  testWidgets('home does not render legacy continuation card', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue seu caminho'), findsNothing);
  });

  testWidgets('hero error does not remove quick actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(_defaultSettingsRepo()),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _ThrowingLastDeliveredCardRepository(),
          ),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.byKey(const Key('home_shortcuts_rail')), findsOneWidget);
  });

  testWidgets('home hero uses subtle entrance animation', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pump();

    expect(find.byType(AnimatedOpacity), findsWidgets);
  });

  testWidgets('home shows updated quick actions', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orações'), findsOneWidget);
    expect(find.text('Liturgia diária'), findsOneWidget);
    expect(find.text('Intenções'), findsOneWidget);
    expect(find.text('Exame Diário'), findsOneWidget);
    expect(find.text('Leituras'), findsOneWidget);
    expect(find.text('Premium'), findsNothing);
  });

  testWidgets('home no longer shows the removed next-step CTA copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
    expect(find.text('Seu próximo passo de oração'), findsNothing);
    expect(
      find.text(
        'Abra a reflexão de agora e comece seu momento de oração sem precisar procurar no app.',
      ),
      findsNothing,
    );
    expect(find.text('Comece por aqui'), findsNothing);
  });

  testWidgets('home header shows text-only brand without grid icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iacula'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
  });

  testWidgets('feature card opens Liturgia Diária screen', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        liturgiaRepo: _FakeLiturgiaRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final liturgiaFinder = find.text('Liturgia diária');
    await tester.dragUntilVisible(
      liturgiaFinder,
      find.byType(CustomScrollView),
      const Offset(0, -100),
    );
    await tester.tap(liturgiaFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LiturgiaScreen), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);
    expect(find.text('Coleta'), findsWidgets);
  });

  testWidgets('home routes Exame Diário to the reading flow', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    final examinationFinder = find.text('Exame Diário');
    await tester.dragUntilVisible(
      examinationFinder,
      find.byType(CustomScrollView),
      const Offset(0, -100),
    );
    await tester.tap(examinationFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(ExaminationReadingScreen), findsOneWidget);
    expect(find.text('Como se confessar?'), findsNothing);
  });

  testWidgets(
    'home routes Sacramento da Confissão to the existing confession flow',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      final featureRailFinder = find.byKey(const Key('home_feature_rail'));
      for (var i = 0; i < 20 && featureRailFinder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(featureRailFinder, findsOneWidget);
      await tester.ensureVisible(featureRailFinder);
      await tester.pumpAndSettle();

      final confessionFinder = find.byKey(
        const Key('home_feature_confissao_card'),
      );
      final featureRailScrollable = find.descendant(
        of: featureRailFinder,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        confessionFinder,
        180,
        scrollable: featureRailScrollable,
      );
      await tester.ensureVisible(confessionFinder);
      await tester.pumpAndSettle();
      expect(confessionFinder, findsOneWidget);
      await tester.tap(confessionFinder);
      await tester.pumpAndSettle();

      expect(find.text('Como se confessar?'), findsOneWidget);
      expect(find.text('Diário para fazer no final do dia'), findsNothing);
    },
  );

  testWidgets('home thematic and saint sections show grouped cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        prayerCatalogRepo: _FakePrayerCatalogRepository(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> reveal(String text) async {
      final finder = find.text(text);
      for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(finder, findsOneWidget);
    }

    await reveal('Encontre uma oração para este momento');
    await reveal('Trabalho');

    expect(find.text('Trabalho'), findsOneWidget);
    expect(find.text('1 oração'), findsWidgets);
  });

  testWidgets('home thematic groups follow fixed order regardless of season', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        prayerCatalogRepo: const _RankingPrayerCatalogRepository(),
        liturgicalSeasonService: const _FakeLiturgicalSeasonService(
          LiturgicalContext(
            season: LiturgicalSeason.lent,
            rank: LiturgicalRank.weekday,
            apiQuotes: <String>[],
          ),
        ),
        now: DateTime(2026, 3, 6),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 20 && find.text('Trabalho').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Trabalho'), findsOneWidget);
    expect(find.text('Família'), findsOneWidget);

    // Fixed order: trabalho < familia < igreja < eucaristica
    final trabalhoY = tester.getTopLeft(find.text('Trabalho')).dy;
    final familiaY = tester.getTopLeft(find.text('Família')).dy;
    expect(trabalhoY, lessThan(familiaY));
  });

  testWidgets('tapping thematic group opens grouped prayer list screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        prayerCatalogRepo: _FakePrayerCatalogRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('feature rail Rosário opens contemplative intro screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 20 && find.text('Rosário').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    final rosaryFinder = find.text('Rosário').first;
    await tester.ensureVisible(rosaryFinder);
    await tester.pump();
    await tester.tap(rosaryFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(RosaryIntroScreen), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);
  });

  testWidgets('feature rail Bíblia opens books screen', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
  });

  testWidgets('home shows monthly novenas section for March 2026', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        now: DateTime(2026, 3, 6),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Novenas deste mês'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Novenas deste mês'), findsOneWidget);
    expect(find.text('Novena a São Patrício'), findsOneWidget);
    expect(find.text('8 a 16 de março'), findsOneWidget);
    expect(find.text('Ver todas'), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);

    final horizontalRails = find.byWidgetPredicate(
      (widget) =>
          widget is ListView && widget.scrollDirection == Axis.horizontal,
    );
    await tester.drag(horizontalRails.last, const Offset(-250, 0));
    await tester.pumpAndSettle();

    expect(find.text('Novena a São José'), findsOneWidget);
    expect(find.text('10 a 18 de março'), findsOneWidget);
    expect(find.text('Novena da Anunciação'), findsNothing);
  });

  testWidgets('home monthly novena card opens seeded challenge detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        now: DateTime(2026, 3, 6),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Novenas deste mês'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final horizontalRails = find.byWidgetPredicate(
      (widget) =>
          widget is ListView && widget.scrollDirection == Axis.horizontal,
    );
    await tester.drag(horizontalRails.last, const Offset(-250, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novena a São José'));
    await tester.pumpAndSettle();

    expect(find.byType(ChallengeDetailScreen), findsOneWidget);
    expect(find.text('Descrição São José'), findsOneWidget);
  });

  testWidgets('home novenas CTA opens challenge library screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        now: DateTime(2026, 3, 6),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Ver todas'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ChallengeLibraryScreen), findsOneWidget);
  });

  testWidgets(
    'home hides monthly novenas section when month has no seeded matches',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
          now: DateTime(2026, 9, 6),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Novenas deste mês'), findsNothing);
      expect(find.text('Novena a São Miguel Arcanjo'), findsNothing);
    },
  );

  testWidgets('home quick action Leituras opens Leituras home', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    final leiturasFinder = find.byKey(const Key('home_leituras_chip'));
    await tester.ensureVisible(leiturasFinder);
    await tester.tap(leiturasFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LeiturasHomePage), findsOneWidget);
  });

  testWidgets('Frases and Leituras share equal top row', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    final frasesCard = find.byKey(const Key('home_custom_phrases_card'));
    final leiturasChip = find.byKey(const Key('home_leituras_chip'));

    expect(frasesCard, findsOneWidget);
    expect(leiturasChip, findsOneWidget);

    final frasesRect = tester.getRect(frasesCard);
    final leiturasRect = tester.getRect(leiturasChip);

    expect((frasesRect.top - leiturasRect.top).abs(), lessThan(1));
    expect((frasesRect.width - leiturasRect.width).abs(), lessThan(1));
  });

  testWidgets('home action cards keep equal heights for long labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    final intentionsCard = find.byKey(const Key('home_action_intencoes'));
    final examinationCard = find.byKey(const Key('home_action_exame'));

    expect(intentionsCard, findsOneWidget);
    expect(examinationCard, findsOneWidget);

    final intentionsRect = tester.getRect(intentionsCard);
    final examinationRect = tester.getRect(examinationCard);

    expect((intentionsRect.height - examinationRect.height).abs(), lessThan(1));
    expect((intentionsRect.top - examinationRect.top).abs(), lessThan(1));
    expect(intentionsRect.height, lessThan(96));
  });
}
