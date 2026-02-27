import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/presentation/liturgia_screen.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
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

Widget _buildApp({
  required _FakeSettingsRepository settingsRepo,
  required _FakeLastDeliveredCardRepository lastCardRepo,
  _FakeLiturgiaRepository? liturgiaRepo,
  Map<String, WidgetBuilder>? routes,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      lastDeliveredCardRepositoryProvider.overrideWithValue(lastCardRepo),
      if (liturgiaRepo != null)
        liturgiaCacheRepositoryProvider.overrideWithValue(liturgiaRepo),
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
    expect(find.text('Conhecer Premium'), findsOneWidget);
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
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    expect(find.text('Bem vindo!'), findsOneWidget);
    expect(find.text('Destaques'), findsNothing);
    await reveal('Sugestão do Dia');
    await reveal('Orações temáticas');
    await reveal('Orações de Santos');
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
    expect(find.text('Liturgia'), findsOneWidget);
    expect(find.text('Rosário 📿'), findsOneWidget);
    expect(find.text('Novenas'), findsOneWidget);
    expect(find.textContaining('Doutrina'), findsOneWidget);
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

    await tester.tap(find.text('Liturgia'));
    await tester.pumpAndSettle();

    expect(find.byType(LiturgiaScreen), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);
    expect(find.text('Coleta: Coleta'), findsOneWidget);
  });

  testWidgets('rosario quick action shows em breve dialog', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rosário 📿'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });

  testWidgets('novenas quick action navigates to prayer collections',
      (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novenas'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });
}
