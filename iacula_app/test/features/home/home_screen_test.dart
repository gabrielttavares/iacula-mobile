import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/presentation/liturgia_screen.dart';
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

Widget _buildApp({
  required _FakeSettingsRepository settingsRepo,
  required _FakeLastDeliveredCardRepository lastCardRepo,
  _FakeLiturgiaRepository? liturgiaRepo,
  PrayerCatalogRepository? prayerCatalogRepo,
  LiturgicalSeasonService? liturgicalSeasonService,
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
      if (liturgicalSeasonService != null)
        liturgicalSeasonServiceProvider.overrideWithValue(liturgicalSeasonService),
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

    final nav = tester.widget<CupertinoSliverNavigationBar>(
      find.byType(CupertinoSliverNavigationBar),
    );
    final greeting = (nav.largeTitle! as Text).data ?? '';
    expect(greeting, contains('Bem vindo'));
    expect(find.text('Destaques'), findsNothing);
    await reveal('Minhas frases');
    await reveal('Sugestão de oração');
    await reveal('Orações Temáticas');
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
    expect(find.byKey(const Key('home_action_grid')), findsOneWidget);
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
    expect(find.byKey(const Key('home_action_grid')), findsOneWidget);
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
    expect(find.text('Liturgia Diária'), findsOneWidget);
    expect(find.text('Intenções'), findsOneWidget);
    expect(find.text('Exame'), findsOneWidget);
    expect(find.text('Leituras'), findsOneWidget);
    expect(find.text('Premium'), findsNothing);
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
    expect(find.byIcon(CupertinoIcons.circle_grid_3x3_fill), findsNothing);
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

    final liturgiaFinder = find.text('Liturgia Diária');
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

    await reveal('Orações Temáticas');
    await reveal('Trabalho');

    expect(find.text('Trabalho'), findsOneWidget);
    expect(find.text('1 oração'), findsWidgets);
  });

  testWidgets('home thematic ranking reflects lent friday context', (
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

    for (var i = 0; i < 20 && find.text('Igreja').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Igreja'), findsOneWidget);
    expect(find.text('Família'), findsOneWidget);

    final igrejaY = tester.getTopLeft(find.text('Igreja')).dy;
    final familiaY = tester.getTopLeft(find.text('Família')).dy;
    expect(igrejaY, lessThan(familiaY));
  });

  testWidgets('home thematic ranking falls back to useful daily in ordinary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        prayerCatalogRepo: const _RankingPrayerCatalogRepository(),
        liturgicalSeasonService: const _FakeLiturgicalSeasonService(
          LiturgicalContext(
            season: LiturgicalSeason.ordinary,
            rank: LiturgicalRank.weekday,
            apiQuotes: <String>[],
            isFallback: true,
          ),
        ),
        now: DateTime(2026, 3, 4),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 20 && find.text('Igreja').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Igreja'), findsOneWidget);
    expect(find.text('Família'), findsOneWidget);

    final familiaY = tester.getTopLeft(find.text('Família')).dy;
    final igrejaY = tester.getTopLeft(find.text('Igreja')).dy;
    expect(familiaY, lessThan(igrejaY));
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

    for (
      var i = 0;
      i < 20 && find.text('Virgem Maria').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    final groupFinder = find.text('Virgem Maria').first;
    await tester.ensureVisible(groupFinder);
    await tester.pumpAndSettle();
    await tester.tap(groupFinder);
    await tester.pumpAndSettle();

    expect(find.byType(PrayerCatalogGroupScreen), findsOneWidget);
    expect(find.text('Salve Rainha'), findsOneWidget);
    expect(find.text('Ave Maria'), findsOneWidget);
    expect(find.text('Ao Anjo da Guarda'), findsNothing);
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

    for (var i = 0; i < 20 && find.text('Bíblia').evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 200));
    }

    final horizontalRail = find.byWidgetPredicate(
      (widget) =>
          widget is ListView && widget.scrollDirection == Axis.horizontal,
    );
    for (var i = 0; i < 10 && find.text('Bíblia').evaluate().isEmpty; i++) {
      await tester.drag(
        horizontalRail,
        const Offset(-140, 0),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    final bibleFinder = find.text('Bíblia').first;
    await tester.ensureVisible(bibleFinder);
    await tester.pump();
    await tester.tap(bibleFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(BibleBooksScreen), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);
  });

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
}
