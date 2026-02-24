import 'package:flutter/material.dart';
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
    child: MaterialApp(
      routes: routes ?? const {},
      home: const HomeScreen(),
    ),
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
  testWidgets('home card renders last delivered quote and feast label', (
    tester,
  ) async {
    final settingsRepo = _FakeSettingsRepository(
      Settings.defaults.copyWith(language: 'pt-br', intervalMinutes: 20),
    );
    final lastCardRepo = _FakeLastDeliveredCardRepository(
      LastDeliveredCard(
        quoteText: 'Sede santos.',
        theme: 'Santidade',
        season: 'ordinary',
        deliveredAt: DateTime(2026, 2, 21, 10, 20),
        feast: 'all-saints',
        feastName: 'Todos os Santos',
      ),
    );

    await tester.pumpWidget(
      _buildApp(settingsRepo: settingsRepo, lastCardRepo: lastCardRepo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your'), findsOneWidget);
    expect(find.text('Design Course'), findsOneWidget);
    expect(find.text('Sede santos.'), findsOneWidget);
    expect(find.text('Todos os Santos'), findsOneWidget);
  });

  testWidgets(
    'home card falls back to season label when feast name is absent',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Permanecei em mim.'), findsOneWidget);
      expect(find.text('tempo da quaresma'), findsOneWidget);
    },
  );

  testWidgets('renders search bar dummy', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search for course'), findsOneWidget);
  });

  testWidgets('renders Category section title', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsOneWidget);
  });

  testWidgets('quick action opens Liturgia Diária screen', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        settingsRepo: _defaultSettingsRepo(),
        lastCardRepo: _defaultLastCardRepo(),
        liturgiaRepo: _FakeLiturgiaRepository(),
        routes: {LiturgiaScreen.routeName: (_) => const LiturgiaScreen()},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liturgia Diária'), findsOneWidget);
    await tester.ensureVisible(find.text('Liturgia Diária'));
    await tester.tap(find.text('Liturgia Diária'));
    await tester.pumpAndSettle();

    expect(find.byType(LiturgiaScreen), findsOneWidget);
    expect(find.text('Domingo'), findsOneWidget);
  });

  testWidgets(
    'quick-action row contains only three free actions',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      // Free quick-actions present
      expect(find.text('Orações'), findsOneWidget);
      expect(find.text('Novenas'), findsOneWidget);
      expect(find.text('Liturgia Diária'), findsOneWidget);

      // Rosário NOT in quick-action row (it's in premium section)
      // Find the horizontal scroll row and verify Rosário is not a descendant
      final quickActionRow = find.byType(SingleChildScrollView).first;
      expect(
        find.descendant(of: quickActionRow, matching: find.text('Rosário')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'premium section shows Rosário card below quote',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      // Popular Course heading exists
      expect(find.text('Popular Course'), findsOneWidget);

      // Rosário exists on the page (in premium section)
      expect(find.text('Rosário'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Rosário in premium section opens premium modal',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Rosário'));
      await tester.tap(find.text('Rosário'));
      await tester.pumpAndSettle();

      expect(find.text('Funcionalidade Premium'), findsOneWidget);
      expect(find.text('Desbloquear Agora'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Novenas opens free placeholder screen',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(
          settingsRepo: _defaultSettingsRepo(),
          lastCardRepo: _defaultLastCardRepo(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Novenas'));
      await tester.tap(find.text('Novenas'));
      await tester.pumpAndSettle();

      // Novenas placeholder screen has AppBar with 'Novenas' and body 'Em breve...'
      expect(find.text('Em breve...'), findsOneWidget);
    },
  );
}
