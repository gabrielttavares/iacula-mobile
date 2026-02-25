import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/infrastructure/services/fallback_liturgical_season_service.dart';

void main() {
  test('FallbackLiturgicalSeasonService returns context with isFallback=true',
      () async {
    const service = FallbackLiturgicalSeasonService();
    final context = await service.getCurrentContext();
    expect(context.isFallback, true);
  });

  test('FallbackLiturgicalSeasonService returns ordinary season', () async {
    const service = FallbackLiturgicalSeasonService();
    final context = await service.getCurrentContext();
    expect(context.season.name, 'ordinary');
  });
}
