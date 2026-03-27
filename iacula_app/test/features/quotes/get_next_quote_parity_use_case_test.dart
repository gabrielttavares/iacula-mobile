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
  _FakeSeasonService(this._context);
  final LiturgicalContext _context;

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async => _context.season;

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async => _context;
}

class _FakeQuoteContentRepository implements QuoteContentRepository {
  _FakeQuoteContentRepository({
    required this.seasonal,
    required this.images,
    this.feastQuotes = const <String>[],
    this.feastImage,
  });

  final Map<String, DayQuotes> seasonal;
  final List<String> images;
  final List<String> feastQuotes;
  final String? feastImage;
  String? lastFeastQuotesSlug;
  String? lastFeastImageSlug;

  @override
  Future<Map<String, DayQuotes>> loadQuotes({required String language, required LiturgicalSeason season}) async {
    return seasonal;
  }

  @override
  Future<List<String>> listDayImages({required int dayOfWeek, required LiturgicalSeason season}) async {
    return images;
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async {
    lastFeastQuotesSlug = feastSlug;
    return feastQuotes;
  }

  @override
  Future<String?> getFeastImagePath(String feastSlug) async {
    lastFeastImageSlug = feastSlug;
    return feastImage;
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
  test('uses seasonal pool while feast quotes are disabled', () async {
    final repo = _FakeIndicesRepository();
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(
        seasonal: {
          '1': const DayQuotes(day: 'Domingo', theme: 'Tema comum', quotes: ['Sazonal']),
        },
        images: ['img-ordinary-1'],
        feastQuotes: const ['Amar a Deus.', 'Confiar em Deus'],
        feastImage: 'img-feast',
      ),
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(
        const LiturgicalContext(
          season: LiturgicalSeason.ordinary,
          rank: LiturgicalRank.solemnity,
          feast: 'all-saints',
          feastName: 'todos os santos',
          apiQuotes: <String>['amar a deus', 'Servir com alegria'],
        ),
      ),
    );

    final first = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 2, 22),
      liturgicalSeasonEnabled: true,
    );
    final second = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 2, 22),
      liturgicalSeasonEnabled: true,
    );

    expect(first.text, 'Sazonal');
    expect(second.text, 'Sazonal');
    expect(first.imagePath, 'img-ordinary-1');
    expect(first.feast, isNull);
    expect(first.feastName, isNull);
  });

  test('falls back to seasonal quotes when feast pool is empty', () async {
    final repo = _FakeIndicesRepository();
    final useCase = GetNextQuoteUseCase(
      contentRepository: _FakeQuoteContentRepository(
        seasonal: {
          '1': const DayQuotes(day: 'Domingo', theme: 'Tema comum', quotes: ['Sazonal']),
        },
        images: ['img-ordinary-1'],
        feastQuotes: const <String>[],
      ),
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(
        const LiturgicalContext(
          season: LiturgicalSeason.ordinary,
          rank: LiturgicalRank.solemnity,
          feast: 'all-saints',
          feastName: 'todos os santos',
          apiQuotes: <String>[],
        ),
      ),
    );

    final quote = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 2, 22),
      liturgicalSeasonEnabled: true,
    );

    expect(quote.text, 'Sazonal');
    expect(quote.imagePath, 'img-ordinary-1');
    expect(quote.feast, isNull);
  });

  test('does not lookup feast quotes or images while feature is disabled', () async {
    final repo = _FakeIndicesRepository();
    final content = _FakeQuoteContentRepository(
      seasonal: {
        '1': const DayQuotes(day: 'Domingo', theme: 'Tema comum', quotes: ['Sazonal']),
      },
      images: ['img-ordinary-1'],
      feastQuotes: const ['Vinde, Espirito Santo'],
      feastImage: 'img-feast',
    );
    final useCase = GetNextQuoteUseCase(
      contentRepository: content,
      indicesRepository: repo,
      liturgicalSeasonService: _FakeSeasonService(
        const LiturgicalContext(
          season: LiturgicalSeason.easter,
          rank: LiturgicalRank.solemnity,
          feast: 'pentecost',
          feastName: 'domingo de pentecostes',
          apiQuotes: <String>[],
        ),
      ),
    );

    final quote = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 5, 24),
      liturgicalSeasonEnabled: true,
    );

    expect(quote.feast, isNull);
    expect(content.lastFeastQuotesSlug, isNull);
    expect(content.lastFeastImageSlug, isNull);
  });
}
