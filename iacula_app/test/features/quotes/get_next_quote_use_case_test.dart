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

class _ThrowingSeasonService implements LiturgicalSeasonService {
  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    throw StateError('liturgical service should not be used');
  }

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    throw StateError('liturgical service should not be used');
  }
}

class _FakeQuoteContentRepository implements QuoteContentRepository {
  final Map<String, DayQuotes> _quotes;

  _FakeQuoteContentRepository({Map<String, DayQuotes>? quotes})
    : _quotes = quotes ?? {
        '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['Q1', 'Q2']),
      };

  @override
  Future<Map<String, DayQuotes>> loadQuotes({required String language, required LiturgicalSeason season}) async {
    return _quotes;
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

class _ResettingIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices indices = QuoteIndices.empty(1);

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async {
    if (indices.lastDay != dayOfWeek) {
      indices = QuoteIndices.empty(dayOfWeek);
    }
    return indices;
  }

  @override
  Future<void> save(QuoteIndices value) async {
    indices = value;
  }
}

void main() {
  test('call omits liturgicalSeasonEnabled does not touch liturgical service', () async {
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(),
      indicesRepository: _FakeIndicesRepository(),
      liturgicalSeasonService: _ThrowingSeasonService(),
    );

    final result = await useCase.call(language: 'pt-br', now: DateTime(2026, 2, 22));
    expect(result.text, 'Q1');
    expect(result.season, LiturgicalSeason.ordinary);
  });

  test('fetchBatch omits liturgicalSeasonEnabled does not touch liturgical service', () async {
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(
        quotes: {
          '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['Q1']),
        },
      ),
      indicesRepository: _FakeIndicesRepository(),
      liturgicalSeasonService: _ThrowingSeasonService(),
    );

    final batch = await useCase.fetchBatch(
      language: 'pt-br',
      count: 1,
      startTime: DateTime(2026, 2, 22, 10),
      intervalMinutes: 15,
    );
    expect(batch, hasLength(1));
    expect(batch.single.season, LiturgicalSeason.ordinary);
  });

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

  test('fetchBatch uses day pool per scheduled instant across midnight', () async {
    final repo = _FakeIndicesRepository();
    final twoDayRepo = _FakeQuoteContentRepository(
      quotes: {
        '1': const DayQuotes(day: 'Domingo', theme: 'Dom', quotes: ['DomA', 'DomB']),
        '2': const DayQuotes(day: 'Segunda', theme: 'Seg', quotes: ['SegA', 'SegB']),
      },
    );
    final useCase = GetNextQuoteUseCase(
      contentRepository: twoDayRepo,
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(),
    );

    final start = DateTime(2026, 3, 22, 23, 40);
    final batch = await useCase.fetchBatch(
      language: 'pt-br',
      count: 2,
      startTime: start,
      intervalMinutes: 15,
    );

    expect(batch[0].dayOfWeek, 1);
    expect(batch[0].text, 'DomA');
    expect(batch[1].dayOfWeek, 2);
    expect(batch[1].text, 'SegA');
  });

  test('fetchBatch keeps anchor day cursor when crossing midnight', () async {
    final repo = _ResettingIndicesRepository();
    final twoDayRepo = _FakeQuoteContentRepository(
      quotes: {
        '1': const DayQuotes(
          day: 'Domingo',
          theme: 'Dom',
          quotes: ['DomA', 'DomB', 'DomC'],
        ),
        '2': const DayQuotes(day: 'Segunda', theme: 'Seg', quotes: ['SegA', 'SegB']),
      },
    );
    final useCase = GetNextQuoteUseCase(
      contentRepository: twoDayRepo,
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(),
    );

    final start = DateTime(2026, 3, 22, 23, 40);
    final immediate = await useCase.call(language: 'pt-br', now: start);
    expect(immediate.text, 'DomA');

    await useCase.fetchBatch(
      language: 'pt-br',
      count: 2,
      startTime: start,
      intervalMinutes: 15,
    );

    final nextSameDay = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 3, 22, 23, 41),
    );
    expect(nextSameDay.text, 'DomC');
  });
}
