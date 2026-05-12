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
    expect(result.text, 'Q1');
    expect(result.season, LiturgicalSeason.ordinary);
  });

  test('returns sequential quote and updates indices', () async {
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
    expect(result.text, 'Q1');
    expect(result.imagePath, 'img1');

    final next = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 2, 22),
    );
    expect(next.text, 'Q2');
    expect(next.imagePath, 'img2');
  });

  test('prevents consecutive quote repeats', () async {
    final repo = _FakeIndicesRepository();
    // Set initial lastQuote to 'Q1' to simulate previous selection
    repo.indices = QuoteIndices(
      quoteIndices: {1: 0},
      imageIndices: {},
      lastDay: 1,
      lastQuote: 'Q1',
    );
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
    // Should skip Q1 and select Q2
    expect(result.text, 'Q2');
    expect(repo.indices.lastQuote, 'Q2');
  });
}
