import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/saint_of_day.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/saint_repository.dart';
import 'package:iacula_app/features/liturgy_hours/presentation/liturgy_hours_landing_screen.dart';

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  const _FakeLiturgicalSeasonService(this.context);

  final LiturgicalContext context;

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async =>
      context;

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async =>
      context.season;
}

final class _FakeSaintRepository implements SaintRepository {
  @override
  Future<SaintOfDay?> getSaintForDate(DateTime date) async {
    return SaintOfDay(
      date: date,
      name: 'São José',
      biographyParagraphs: const ['Guardião fiel da Sagrada Família.'],
    );
  }
}

final class _NoSaintRepository implements SaintRepository {
  @override
  Future<SaintOfDay?> getSaintForDate(DateTime date) async => null;
}

void main() {
  testWidgets('shows the live liturgical season and saint of day', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liturgicalSeasonServiceProvider.overrideWithValue(
            const _FakeLiturgicalSeasonService(
              LiturgicalContext(
                season: LiturgicalSeason.advent,
                rank: LiturgicalRank.weekday,
                apiQuotes: <String>[],
              ),
            ),
          ),
          saintRepositoryProvider.overrideWithValue(_FakeSaintRepository()),
        ],
        child: const CupertinoApp(home: LiturgyHoursLandingScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tempo do Advento'), findsOneWidget);
    expect(find.text('Tempo Comum'), findsNothing);
    expect(find.text('São José'), findsOneWidget);
    expect(find.text('Guardião fiel da Sagrada Família.'), findsOneWidget);
  });

  testWidgets('shows a devotional fallback when saint data is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liturgicalSeasonServiceProvider.overrideWithValue(
            const _FakeLiturgicalSeasonService(
              LiturgicalContext(
                season: LiturgicalSeason.lent,
                rank: LiturgicalRank.weekday,
                apiQuotes: <String>[],
              ),
            ),
          ),
          saintRepositoryProvider.overrideWithValue(_NoSaintRepository()),
        ],
        child: const CupertinoApp(home: LiturgyHoursLandingScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tempo da Quaresma'), findsOneWidget);
    expect(find.text('Comunhão dos santos'), findsOneWidget);
    expect(
      find.text(
        'Hoje a Igreja convida você a rezar em sintonia com o tempo litúrgico.',
      ),
      findsOneWidget,
    );
  });
}
