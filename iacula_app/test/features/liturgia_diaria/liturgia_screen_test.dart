import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
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

Widget _buildApp(_FakeLiturgiaRepository repository) {
  return ProviderScope(
    overrides: [liturgiaCacheRepositoryProvider.overrideWithValue(repository)],
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

  testWidgets(
    'renders Cupertino large title, day selector and segmented control',
    (tester) async {
      await tester.pumpWidget(_buildApp(repository));
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

  testWidgets('switches day when tapping date selector', (tester) async {
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('7o Domingo do Tempo Comum'), findsOneWidget);
    await tester.tap(find.text('Seg 23/02'));
    await tester.pumpAndSettle();

    expect(find.text('2a Feira da Semana'), findsOneWidget);
  });

  testWidgets('switches content with segmented control', (tester) async {
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('Coleta: Coleta'), findsOneWidget);

    await tester.tap(find.text('Leituras'));
    await tester.pumpAndSettle();
    expect(find.text('Leitura'), findsOneWidget);

    await tester.tap(find.text('Antífonas'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Entrada: Antifona'), findsOneWidget);
  });

  testWidgets('calendar confirm selects date inside current window', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(repository));
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

    await tester.pumpWidget(_buildApp(reanchorRepository));
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
}
