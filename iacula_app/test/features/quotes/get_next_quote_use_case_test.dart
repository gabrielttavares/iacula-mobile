import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/quotes/application/use_cases/get_next_quote_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote_indices.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_indices_repository.dart';
import 'package:iacula_app/features/quotes/infrastructure/repositories/in_memory_disabled_quotes_repository.dart';
import 'package:iacula_app/features/quotes/infrastructure/repositories/in_memory_quote_indices_repository.dart';

class _EmptyCustomPhraseRepository implements CustomPhraseRepository {
  @override
  Future<List<CustomPhrase>> listAll() async => const [];
  @override
  Future<CustomPhrase?> getById(String id) async => null;
  @override
  Future<void> save(CustomPhrase phrase) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Stream<List<CustomPhrase>> watchAll() => Stream.value(const []);
}

class _FakeQuoteContentRepository implements QuoteContentRepository {
  final Map<String, DayQuotes> _quotes;

  _FakeQuoteContentRepository({Map<String, DayQuotes>? quotes})
    : _quotes =
          quotes ??
          {
            '1': const DayQuotes(
              day: 'Domingo',
              theme: 'Tema',
              quotes: ['Q1', 'Q2'],
            ),
          };

  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async {
    return _quotes;
  }

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async {
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
  test('call uses ordinary content without liturgical service', () async {
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(),
      indicesRepository: _FakeIndicesRepository(),
      disabledQuotesRepository: InMemoryDisabledQuotesRepository(),
      customPhraseRepository: _EmptyCustomPhraseRepository(),
    );

    final result = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 2, 22),
    );
    expect({'Q1', 'Q2'}, contains(result.text));
    expect(result.season, LiturgicalSeason.ordinary);
  });

  test(
    'returns different quote and image before the pool is exhausted',
    () async {
      final repo = _FakeIndicesRepository();
      final useCase = GetNextQuoteUseCase(
        contentRepository: _FakeQuoteContentRepository(),
        indicesRepository: repo,
        disabledQuotesRepository: InMemoryDisabledQuotesRepository(),
        customPhraseRepository: _EmptyCustomPhraseRepository(),
      );

      final result = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 2, 22),
      ); // Sunday

      final next = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 2, 22),
      );
      expect({'Q1', 'Q2'}, contains(result.text));
      expect({'Q1', 'Q2'}, contains(next.text));
      expect(next.text, isNot(result.text));
      expect({'img1', 'img2'}, contains(result.imagePath));
      expect({'img1', 'img2'}, contains(next.imagePath));
      expect(next.imagePath, isNot(result.imagePath));
    },
  );

  test(
    'returns every quote before repeating within the same weekday',
    () async {
      final useCase = GetNextQuoteUseCase(
        contentRepository: _FakeQuoteContentRepository(
          quotes: {
            '1': const DayQuotes(
              day: 'Domingo',
              theme: 'Tema',
              quotes: ['Q1', 'Q2', 'Q3'],
            ),
          },
        ),
        indicesRepository: InMemoryQuoteIndicesRepository(),
        disabledQuotesRepository: InMemoryDisabledQuotesRepository(),
        customPhraseRepository: _EmptyCustomPhraseRepository(),
      );

      final first = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 2, 22),
      ); // Sunday
      final second = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 2, 22, 0, 1),
      );
      final third = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 2, 22, 0, 2),
      );

      expect({first.text, second.text, third.text}, hasLength(3));
    },
  );

  test('preserves weekday rotation after visiting a future weekday', () async {
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(
        quotes: {
          '5': const DayQuotes(
            day: 'Quinta-feira',
            theme: 'Eucaristia',
            quotes: ['T1', 'T2', 'T3'],
          ),
          '6': const DayQuotes(
            day: 'Sexta-feira',
            theme: 'Cruz',
            quotes: ['F1', 'F2'],
          ),
        },
      ),
      indicesRepository: InMemoryQuoteIndicesRepository(),
      disabledQuotesRepository: InMemoryDisabledQuotesRepository(),
      customPhraseRepository: _EmptyCustomPhraseRepository(),
    );

    final firstThursday = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 5, 14, 10),
    );
    await useCase.call(language: 'pt-br', now: DateTime(2026, 5, 15, 10));
    final resumedThursday = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 5, 14, 11),
    );

    expect(resumedThursday.text, isNot(firstThursday.text));
    expect(resumedThursday.imagePath, isNot(firstThursday.imagePath));
  });
}
