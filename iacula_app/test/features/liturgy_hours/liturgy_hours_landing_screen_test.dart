import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/liturgy_hours/presentation/liturgy_hours_landing_screen.dart';

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  const _FakeLiturgicalSeasonService(this.context);

  final LiturgicalContext context;

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async => context;

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async =>
      context.season;
}

void main() {
  testWidgets('shows the live liturgical season in the header', (tester) async {
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
        ],
        child: const CupertinoApp(home: LiturgyHoursLandingScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tempo do Advento'), findsOneWidget);
    expect(find.text('Tempo Comum'), findsNothing);
  });
}
