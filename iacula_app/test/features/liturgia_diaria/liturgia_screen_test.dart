import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/saint_of_day.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/saint_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/presentation/liturgia_screen.dart';

final class _FakeLiturgiaRepository implements LiturgiaRepository {
  _FakeLiturgiaRepository({
    required this.periodDays,
    Map<String, LiturgyDay>? byDate,
  }) : _byDate = byDate ?? <String, LiturgyDay>{};

  final List<LiturgyDay> periodDays;
  final Map<String, LiturgyDay> _byDate;

  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async {
    return _byDate[_dateKey(date)];
  }

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int daysCount) async {
    return periodDays.take(daysCount).toList(growable: false);
  }

  String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}-${d.month}-${d.day}';
  }
}

final class _FakeSaintRepository implements SaintRepository {
  _FakeSaintRepository(this._items);

  final Map<String, SaintOfDay> _items;

  @override
  Future<SaintOfDay?> getSaintForDate(DateTime date) async {
    return _items[_dateKey(date)];
  }

  String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}-${d.month}-${d.day}';
  }
}

Widget _buildApp(
  _FakeLiturgiaRepository repository, {
  _FakeSaintRepository? saintRepository,
}) {
  return ProviderScope(
    overrides: [
      liturgiaCacheRepositoryProvider.overrideWithValue(repository),
      saintRepositoryProvider.overrideWithValue(
        saintRepository ?? _FakeSaintRepository(<String, SaintOfDay>{}),
      ),
    ],
    child: const CupertinoApp(home: LiturgiaScreen()),
  );
}

LiturgyDay _day({required DateTime date, required String title}) {
  return LiturgyDay(
    date: date,
    title: title,
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
  );
}

void main() {
  final repository = _FakeLiturgiaRepository(
    periodDays: [
      _day(date: DateTime(2026, 2, 22), title: '7o Domingo do Tempo Comum'),
      _day(date: DateTime(2026, 2, 23), title: '2a Feira da Semana'),
    ],
  );
  final saintRepository = _FakeSaintRepository({
    '2026-2-22': SaintOfDay(
      date: DateTime(2026, 2, 22),
      name: 'Santa Rosa de Viterbo',
      biographyParagraphs: const ['Primeiro parágrafo', 'Segundo parágrafo'],
      imageAssetPath: 'assets/placeholders/saint-placeholder.png',
    ),
    '2026-2-23': SaintOfDay(
      date: DateTime(2026, 2, 23),
      name: 'São Policarpo',
      biographyParagraphs: const ['Texto de São Policarpo'],
      imageAssetPath: 'assets/placeholders/saint-placeholder.png',
    ),
  });

  testWidgets(
    'renders Cupertino large title, day selector and segmented control',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(repository, saintRepository: saintRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Liturgia'), findsOneWidget);
      expect(find.text('Dom 22/02'), findsOneWidget);
      expect(find.text('Seg 23/02'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CupertinoSlidingSegmentedControl,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows Cupertino back button when pushed and pops on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liturgiaCacheRepositoryProvider.overrideWithValue(repository),
          saintRepositoryProvider.overrideWithValue(saintRepository),
        ],
        child: CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(middle: Text('Home')),
              child: Center(
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => const LiturgiaScreen(),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(LiturgiaScreen), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('switches day when tapping date selector', (tester) async {
    await tester.pumpWidget(
      _buildApp(repository, saintRepository: saintRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('7o Domingo do Tempo Comum'), findsOneWidget);
    await tester.tap(find.text('Seg 23/02'));
    await tester.pumpAndSettle();

    expect(find.text('2a Feira da Semana'), findsOneWidget);
  });

  testWidgets('switches content with segmented control', (tester) async {
    await tester.pumpWidget(
      _buildApp(repository, saintRepository: saintRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coleta'), findsAtLeast(1));

    await tester.tap(find.text('Leituras'));
    await tester.pumpAndSettle();
    expect(find.text('Leitura'), findsOneWidget);

    await tester.tap(find.text('Antífonas'));
    await tester.pumpAndSettle();
    expect(find.text('Entrada'), findsOneWidget);
    expect(find.text('Antifona'), findsOneWidget);
  });

  testWidgets('calendar confirm selects date inside current window', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(repository, saintRepository: saintRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendário'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha a data'), findsOneWidget);
    Navigator.of(
      tester.element(find.text('Escolha a data')),
    ).pop(DateTime(2026, 2, 23));
    await tester.pumpAndSettle();

    expect(find.text('2a Feira da Semana'), findsOneWidget);
  });

  testWidgets('calendar out-of-window date re-anchors and reloads period', (
    tester,
  ) async {
    final reanchorRepository = _FakeLiturgiaRepository(
      periodDays: [
        _day(date: DateTime(2026, 2, 22), title: '7o Domingo do Tempo Comum'),
        _day(date: DateTime(2026, 2, 23), title: '2a Feira da Semana'),
      ],
      byDate: {
        '2026-2-25': _day(
          date: DateTime(2026, 2, 25),
          title: 'Quarta Especial',
        ),
      },
    );
    final reanchorSaintRepository = _FakeSaintRepository({
      '2026-2-25': SaintOfDay(
        date: DateTime(2026, 2, 25),
        name: 'São Cesário',
        biographyParagraphs: const ['Texto especial'],
        imageAssetPath: 'assets/placeholders/saint-placeholder.png',
      ),
    });

    await tester.pumpWidget(
      _buildApp(reanchorRepository, saintRepository: reanchorSaintRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendário'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha a data'), findsOneWidget);
    Navigator.of(
      tester.element(find.text('Escolha a data')),
    ).pop(DateTime(2026, 2, 25));
    await tester.pumpAndSettle();

    expect(find.text('Quarta Especial'), findsOneWidget);
  });

  testWidgets(
    'renders santo do dia section and updates when selected date changes',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(repository, saintRepository: saintRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Santo do dia'), findsOneWidget);
      expect(find.text('Santa Rosa de Viterbo'), findsOneWidget);
      expect(find.text('Primeiro parágrafo'), findsOneWidget);
      expect(find.text('Segundo parágrafo'), findsOneWidget);

      await tester.tap(find.text('Seg 23/02'));
      await tester.pumpAndSettle();

      expect(find.text('São Policarpo'), findsOneWidget);
      expect(find.text('Texto de São Policarpo'), findsOneWidget);
    },
  );

  testWidgets(
    'renders a devotional santo do dia fallback when no saint is available',
    (tester) async {
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Santo do dia'), findsOneWidget);
      expect(find.text('Comunhão dos santos'), findsOneWidget);
      expect(
        find.text(
          'Hoje a Igreja convida você a rezar em sintonia com o tempo litúrgico.',
        ),
        findsOneWidget,
      );
    },
  );
}
