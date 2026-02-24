import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/presentation/liturgia_screen.dart';

final class _FakeLiturgiaRepository implements LiturgiaRepository {
  _FakeLiturgiaRepository(this.days);

  final List<LiturgyDay> days;

  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async => days.first;

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int daysCount) async {
    return days.take(daysCount).toList(growable: false);
  }
}

Widget _buildApp(_FakeLiturgiaRepository repository) {
  return ProviderScope(
    overrides: [liturgiaCacheRepositoryProvider.overrideWithValue(repository)],
    child: const CupertinoApp(home: LiturgiaScreen()),
  );
}

void main() {
  final repository = _FakeLiturgiaRepository([
    LiturgyDay(
      date: DateTime(2026, 2, 22),
      title: '7o Domingo do Tempo Comum',
      color: LiturgyColor.green,
      prayers: const LiturgyPrayer(
        collect: 'Coleta 1',
        offering: 'Oferendas 1',
        communion: 'Comunhao 1',
      ),
      readings: const [
        LiturgyReading(
          reference: 'Ref 1',
          title: 'Primeira leitura',
          text: 'Texto 1',
        ),
      ],
      antiphons: const LiturgyAntiphons(entry: 'Antifona entrada 1'),
    ),
    LiturgyDay(
      date: DateTime(2026, 2, 23),
      title: '2a Feira da Semana',
      color: LiturgyColor.red,
      prayers: const LiturgyPrayer(
        collect: 'Coleta 2',
        offering: 'Oferendas 2',
        communion: 'Comunhao 2',
      ),
      readings: const [
        LiturgyReading(reference: 'Ref 2', title: 'Evangelho', text: 'Texto 2'),
      ],
      antiphons: const LiturgyAntiphons(entry: 'Antifona entrada 2'),
    ),
  ]);

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
    expect(find.textContaining('Coleta: Coleta 2'), findsOneWidget);
  });

  testWidgets('switches content with segmented control', (tester) async {
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('Coleta: Coleta 1'), findsOneWidget);

    await tester.tap(find.text('Leituras'));
    await tester.pumpAndSettle();
    expect(find.text('Primeira leitura'), findsOneWidget);

    await tester.tap(find.text('Antífonas'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Entrada: Antifona entrada 1'), findsOneWidget);
  });

  testWidgets('opens and closes calendar modal sheet', (tester) async {
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendário'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar data'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar data'), findsNothing);
  });
}
