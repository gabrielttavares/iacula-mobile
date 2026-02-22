import 'package:flutter/material.dart';
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
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async {
    for (final day in days) {
      if (day.date.year == date.year &&
          day.date.month == date.month &&
          day.date.day == date.day) {
        return day;
      }
    }
    return null;
  }

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int days) async {
    return this.days.take(days).toList(growable: false);
  }
}

void main() {
  testWidgets('renders liturgy details and switches selected day', (
    tester,
  ) async {
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
          LiturgyReading(
            reference: 'Ref 2',
            title: 'Evangelho',
            text: 'Texto 2',
          ),
        ],
        antiphons: const LiturgyAntiphons(entry: 'Antifona entrada 2'),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liturgiaCacheRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: LiturgiaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liturgia Diária'), findsOneWidget);
    expect(find.text('7o Domingo do Tempo Comum'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Coleta: Coleta 1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Seg 23/02'));
    await tester.pumpAndSettle();

    expect(find.text('2a Feira da Semana'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Coleta: Coleta 2'),
      ),
      findsOneWidget,
    );
  });
}
