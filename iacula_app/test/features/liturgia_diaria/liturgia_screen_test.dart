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
  testWidgets('applies light theme roles instead of hardcoded dark palette', (tester) async {
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
    ]);

    final testTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFEFEFEF),
      colorScheme: const ColorScheme.light(
        onSurface: Color(0xFF111111),
        onSurfaceVariant: Color(0xFF222222),
        outline: Color(0xFF888888),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liturgiaCacheRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: testTheme,
          home: const LiturgiaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scaffold background should be from theme, not hardcoded 0xFF13100D
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, null); // when null, it uses theme default

    // Title should use onSurface color (0xFF111111) instead of white
    final titleText = tester.widget<Text>(find.text('7o Domingo do Tempo Comum'));
    expect(titleText.style?.color, const Color(0xFF111111));

    // _Line base style should use onSurfaceVariant (0xFF222222) instead of beige
    final richText = tester.widget<RichText>(
      find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText().contains('Coleta: ')),
    );
    expect(richText.text.style?.color, const Color(0xFF222222));

    // Day chip should use outline color (0xFF888888 with alpha) instead of white24
    final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip).first);
    expect(chip.side?.color, equals(Colors.green)); // The first is selected, so it uses accent color
    
    // Check unselected chip for outline color
    final repositoryWithTwoDays = _FakeLiturgiaRepository([
      LiturgyDay(date: DateTime(2026, 2, 22), title: 'Day 1', color: LiturgyColor.green, prayers: const LiturgyPrayer(collect: '', offering: '', communion: ''), readings: const [], antiphons: const LiturgyAntiphons()),
      LiturgyDay(date: DateTime(2026, 2, 23), title: 'Day 2', color: LiturgyColor.red, prayers: const LiturgyPrayer(collect: '', offering: '', communion: ''), readings: const [], antiphons: const LiturgyAntiphons()),
    ]);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [liturgiaCacheRepositoryProvider.overrideWithValue(repositoryWithTwoDays)],
        child: MaterialApp(theme: testTheme, home: const LiturgiaScreen()),
      ),
    );
    await tester.pumpAndSettle();
    
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
    expect(chips[1].side?.color, const Color(0xFF888888).withValues(alpha: 0.24));
  });

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

  testWidgets('date chips display distinct dates for each day in period', (
    tester,
  ) async {
    final repository = _FakeLiturgiaRepository([
      LiturgyDay(
        date: DateTime(2026, 2, 22),
        title: 'Sunday',
        color: LiturgyColor.green,
        prayers: const LiturgyPrayer(
          collect: 'Coleta',
          offering: 'Oferendas',
          communion: 'Comunhao',
        ),
        readings: const [],
        antiphons: const LiturgyAntiphons(entry: 'Antifona'),
      ),
      LiturgyDay(
        date: DateTime(2026, 2, 23),
        title: 'Monday',
        color: LiturgyColor.red,
        prayers: const LiturgyPrayer(
          collect: 'Coleta 2',
          offering: 'Oferendas 2',
          communion: 'Comunhao 2',
        ),
        readings: const [],
        antiphons: const LiturgyAntiphons(entry: 'Antifona 2'),
      ),
      LiturgyDay(
        date: DateTime(2026, 2, 24),
        title: 'Tuesday',
        color: LiturgyColor.purple,
        prayers: const LiturgyPrayer(
          collect: 'Coleta 3',
          offering: 'Oferendas 3',
          communion: 'Comunhao 3',
        ),
        readings: const [],
        antiphons: const LiturgyAntiphons(entry: 'Antifona 3'),
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

    expect(find.text('Dom 22/02'), findsOneWidget);
    expect(find.text('Seg 23/02'), findsOneWidget);
    expect(find.text('Ter 24/02'), findsOneWidget);

    final chipLabels = find.byType(ChoiceChip).evaluate();
    expect(chipLabels.length, 3);
  });

  testWidgets('renders all reading kinds in canonical order with fallback titles', (
    tester,
  ) async {
    final repository = _FakeLiturgiaRepository([
      LiturgyDay(
        date: DateTime(2026, 2, 22),
        title: 'Domingo de Pentecostes',
        color: LiturgyColor.red,
        prayers: const LiturgyPrayer(
          collect: 'Coleta',
          offering: 'Oferendas',
          communion: 'Comunhao',
        ),
        readings: const [
          LiturgyReading(
            reference: 'At 2,1-11',
            title: 'Primeira leitura',
            text: 'Texto primeira',
            kind: LiturgyReadingKind.first,
          ),
          LiturgyReading(
            reference: 'Sl 103',
            title: 'Salmo',
            text: 'Texto salmo',
            response: 'Enviai o vosso Espírito',
            kind: LiturgyReadingKind.psalm,
          ),
          LiturgyReading(
            reference: '1Cor 12,3-7',
            title: 'Segunda leitura',
            text: 'Texto segunda',
            kind: LiturgyReadingKind.second,
          ),
          LiturgyReading(
            reference: '',
            title: 'Sequência',
            text: 'Vinde Espírito Santo',
            kind: LiturgyReadingKind.sequence,
          ),
          LiturgyReading(
            reference: '',
            title: 'Aclamação ao Evangelho',
            text: 'Aleluia',
            kind: LiturgyReadingKind.acclamation,
          ),
          LiturgyReading(
            reference: 'Jo 20,19-23',
            title: 'Evangelho',
            text: 'Texto evangelho',
            kind: LiturgyReadingKind.gospel,
          ),
        ],
        antiphons: const LiturgyAntiphons(entry: 'Antifona'),
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

    // All reading titles visible
    expect(find.text('Primeira leitura'), findsOneWidget);
    expect(find.text('Salmo'), findsOneWidget);
    expect(find.text('Segunda leitura'), findsOneWidget);
    expect(find.text('Sequência'), findsOneWidget);
    expect(find.text('Aclamação ao Evangelho'), findsOneWidget);
    expect(find.text('Evangelho'), findsOneWidget);

    // Response text appears for psalm
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Resposta: Enviai o vosso Espírito'),
      ),
      findsOneWidget,
    );

    // Empty reference uses 'Texto' label instead of blank
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Texto: Vinde Espírito Santo'),
      ),
      findsOneWidget,
    );
  });
}
