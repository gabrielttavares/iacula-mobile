import '../../../liturgical/domain/services/liturgical_season_service.dart';
import '../../domain/entities/day_quotes.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_content_repository.dart';
import '../../domain/repositories/quote_indices_repository.dart';
import '../../domain/services/quote_selector.dart';

final class GetNextQuoteUseCase {
  const GetNextQuoteUseCase({
    required QuoteContentRepository contentRepository,
    required QuoteIndicesRepository indicesRepository,
    required LiturgicalSeasonService liturgicalSeasonService,
  })  : _contentRepository = contentRepository,
        _indicesRepository = indicesRepository,
        _liturgicalSeasonService = liturgicalSeasonService;

  final QuoteContentRepository _contentRepository;
  final QuoteIndicesRepository _indicesRepository;
  final LiturgicalSeasonService _liturgicalSeasonService;

  Future<Quote> call({
    required String language,
    DateTime? now,
  }) async {
    final date = now ?? DateTime.now();
    final dayOfWeek = _dayOfWeek1to7(date);
    final context = await _liturgicalSeasonService.getCurrentContext(date: date);

    final seasonalCollection = await _contentRepository.loadQuotes(
      language: language,
      season: context.season,
    );

    final seasonalDay = seasonalCollection[dayOfWeek.toString()];
    final seasonalQuotes = seasonalDay?.quotes ?? const <String>[];

    // TODO: re-enable feast quotes
    // final feastQuotes = context.feast == null
    //     ? const <String>[]
    //     : await _contentRepository.loadFeastQuotes(context.feast!);
    // final mergedFeastQuotes = _mergeDedup(feastQuotes, context.apiQuotes);
    // final useFeastPool = mergedFeastQuotes.isNotEmpty;
    // final quotePool = useFeastPool
    //     ? {
    //         dayOfWeek.toString(): DayQuotes(
    //           day: seasonalDay?.day ?? 'Dia',
    //           theme: context.feastName ?? seasonalDay?.theme ?? 'Festa',
    //           quotes: mergedFeastQuotes,
    //         ),
    //       }
    //     : seasonalCollection;
    const useFeastPool = false;
    final quotePool = seasonalCollection;

    final dayData = quotePool[dayOfWeek.toString()];
    if (dayData == null || dayData.quotes.isEmpty) {
      return Quote(
        text: 'Conteudo indisponivel para hoje.',
        dayOfWeek: dayOfWeek,
        theme: seasonalDay?.theme ?? 'Sem tema',
        season: context.season,
      );
    }

    final indices = await _indicesRepository.load(dayOfWeek: dayOfWeek);
    final currentQuoteIndex = indices.quoteIndices[dayOfWeek] ?? 0;
    final quoteStep = QuoteSelector.getNextIndex(dayData.quotes.length, currentQuoteIndex);

    // TODO: re-enable feast images
    // final feastImagePath = context.feast == null ? null : await _contentRepository.getFeastImagePath(context.feast!);
    final seasonalImages = await _contentRepository.listDayImages(dayOfWeek: dayOfWeek, season: context.season);
    final currentImageIndex = indices.imageIndices[dayOfWeek] ?? 0;

    String? imagePath;
    var nextImageIndex = 0;

    if (seasonalImages.isNotEmpty) {
      final imageStep = QuoteSelector.getNextIndex(seasonalImages.length, currentImageIndex);
      imagePath = seasonalImages[imageStep.currentIndex];
      nextImageIndex = imageStep.nextIndex;
    }

    final text = QuoteSelector.selectQuote(
      collection: quotePool,
      dayOfWeek: dayOfWeek,
      index: currentQuoteIndex,
    );

    if (text == null) {
      return Quote(
        text: seasonalQuotes.isNotEmpty ? seasonalQuotes.first : 'Conteudo indisponivel para hoje.',
        dayOfWeek: dayOfWeek,
        theme: dayData.theme,
        season: context.season,
        imagePath: imagePath,
      );
    }

    await _indicesRepository.save(
      QuoteIndices(
        quoteIndices: {
          ...indices.quoteIndices,
          dayOfWeek: quoteStep.nextIndex,
        },
        imageIndices: {
          ...indices.imageIndices,
          dayOfWeek: nextImageIndex,
        },
        lastDay: dayOfWeek,
      ),
    );

    return Quote(
      text: text,
      dayOfWeek: dayOfWeek,
      theme: dayData.theme,
      season: context.season,
      imagePath: imagePath,
      feast: useFeastPool ? context.feast : null,
      feastName: useFeastPool ? context.feastName : null,
    );
  }

  int _dayOfWeek1to7(DateTime date) {
    // DateTime.weekday: Monday=1 ... Sunday=7
    // Iacula convention: Sunday=1 ... Saturday=7
    return (date.weekday % 7) + 1;
  }

  List<String> _mergeDedup(List<String> curated, List<String> apiQuotes) {
    final merged = <String>[...curated, ...apiQuotes];
    final deduped = <String>[];
    final seen = <String>{};

    for (final quote in merged) {
      final normalized = _normalizeForDedup(quote);
      if (normalized.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      deduped.add(quote);
    }

    return deduped;
  }

  String _normalizeForDedup(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
