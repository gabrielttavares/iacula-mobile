import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/quotes/application/use_cases/get_next_quote_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote_indices.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_indices_repository.dart';

class _FakeSeasonService implements LiturgicalSeasonService {
  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async => LiturgicalSeason.ordinary;

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    return LiturgicalContext.ordinaryFallback;
  }
}

class _FakeQuoteContentRepository implements QuoteContentRepository {
  @override
  Future<Map<String, DayQuotes>> loadQuotes({required String language, required LiturgicalSeason season}) async {
    return {
      '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['Q1', 'Q2']),
    };
  }

  @override
  Future<List<String>> listDayImages({required int dayOfWeek, required LiturgicalSeason season}) async {
    return ['img1', 'img2'];
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async {
    return const <String>[];
  }

  @override
  Future<String?> getFeastImagePath(String feastSlug) async {
    return null;
  }
}

class _FakeIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices indices = QuoteIndices.empty(1);

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async => indices;

  @override
  Future<void> save(QuoteIndices value) async {
    indices = value;
  }
}

void main() {
  test('returns sequential quote and updates indices', () async {
    final repo = _FakeIndicesRepository();
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(),
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(),
    );

    final result = await useCase.call(language: 'pt-br', now: DateTime(2026, 2, 22)); // Sunday
    expect(result.text, 'Q1');
    expect(result.imagePath, 'img1');

    final next = await useCase.call(language: 'pt-br', now: DateTime(2026, 2, 22));
    expect(next.text, 'Q2');
    expect(next.imagePath, 'img2');
  });
}
