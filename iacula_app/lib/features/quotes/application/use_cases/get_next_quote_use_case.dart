import '../../../liturgical/domain/liturgical_season.dart';
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
  }) : _contentRepository = contentRepository,
       _indicesRepository = indicesRepository;

  static const _defaultSeason = LiturgicalSeason.ordinary;

  final QuoteContentRepository _contentRepository;
  final QuoteIndicesRepository _indicesRepository;

  /// Fetches [count] quotes in sequence, loading indices once and saving once
  /// at the end. Much more efficient than calling [call] in a loop.
  Future<List<Quote>> fetchBatch({
    required String language,
    required int count,
    required DateTime startTime,
    required int intervalMinutes,
  }) async {
    if (count <= 0) return const [];

    final quotePool = await _contentRepository.loadQuotes(
      language: language,
      season: _defaultSeason,
    );
    final imageLists = <int, List<String>>{};
    Future<List<String>> imagesForDay(int dayOfWeek) async {
      final cached = imageLists[dayOfWeek];
      if (cached != null) return cached;
      final list = await _contentRepository.listDayImages(
        dayOfWeek: dayOfWeek,
        season: _defaultSeason,
      );
      imageLists[dayOfWeek] = list;
      return list;
    }

    final startDayOfWeek = _dayOfWeek1to7(startTime);
    var indices = await _indicesRepository.load(dayOfWeek: startDayOfWeek);
    final quotes = <Quote>[];

    for (var i = 0; i < count; i++) {
      final quoteAt = startTime.add(
        Duration(minutes: intervalMinutes * (i + 1)),
      );
      final dayOfWeek = _dayOfWeek1to7(quoteAt);
      final dayData = quotePool[dayOfWeek.toString()];
      if (dayData == null || dayData.quotes.isEmpty) {
        quotes.add(
          Quote(
            text: 'Conteudo indisponivel para hoje.',
            dayOfWeek: dayOfWeek,
            theme: dayData?.theme ?? 'Sem tema',
            season: _defaultSeason,
          ),
        );
        continue;
      }

      final currentQuoteIndex = indices.quoteIndices[dayOfWeek] ?? 0;
      final quoteStep = QuoteSelector.getNextIndex(
        dayData.quotes.length,
        currentQuoteIndex,
      );
      final selectedText = _selectNonRepeatingText(
        quotePool: quotePool,
        dayOfWeek: dayOfWeek,
        currentIndex: currentQuoteIndex,
        nextIndex: quoteStep.nextIndex,
        lastQuote: indices.lastQuote,
        fallback: dayData.quotes.first,
      );

      final images = await imagesForDay(dayOfWeek);
      final currentImageIndex = indices.imageIndices[dayOfWeek] ?? 0;
      String? imagePath;
      var nextImageIndex = 0;
      if (images.isNotEmpty) {
        final imageStep = QuoteSelector.getNextIndex(
          images.length,
          currentImageIndex,
        );
        imagePath = images[imageStep.currentIndex];
        nextImageIndex = imageStep.nextIndex;
      }

      indices = QuoteIndices(
        quoteIndices: {
          ...indices.quoteIndices,
          dayOfWeek: selectedText.nextIndex,
        },
        imageIndices: {...indices.imageIndices, dayOfWeek: nextImageIndex},
        lastDay: startDayOfWeek,
        lastQuote: selectedText.text,
      );

      quotes.add(
        Quote(
          text: selectedText.text,
          dayOfWeek: dayOfWeek,
          theme: dayData.theme,
          season: _defaultSeason,
          imagePath: imagePath,
        ),
      );
    }

    await _indicesRepository.save(indices);
    return quotes;
  }

  Future<Quote> call({required String language, DateTime? now}) async {
    final date = now ?? DateTime.now();
    final dayOfWeek = _dayOfWeek1to7(date);
    final quotePool = await _contentRepository.loadQuotes(
      language: language,
      season: _defaultSeason,
    );
    final dayData = quotePool[dayOfWeek.toString()];
    if (dayData == null || dayData.quotes.isEmpty) {
      return Quote(
        text: 'Conteudo indisponivel para hoje.',
        dayOfWeek: dayOfWeek,
        theme: dayData?.theme ?? 'Sem tema',
        season: _defaultSeason,
      );
    }

    final indices = await _indicesRepository.load(dayOfWeek: dayOfWeek);
    final currentQuoteIndex = indices.quoteIndices[dayOfWeek] ?? 0;
    final quoteStep = QuoteSelector.getNextIndex(
      dayData.quotes.length,
      currentQuoteIndex,
    );
    final selectedText = _selectNonRepeatingText(
      quotePool: quotePool,
      dayOfWeek: dayOfWeek,
      currentIndex: currentQuoteIndex,
      nextIndex: quoteStep.nextIndex,
      lastQuote: indices.lastQuote,
      fallback: dayData.quotes.first,
    );

    final images = await _contentRepository.listDayImages(
      dayOfWeek: dayOfWeek,
      season: _defaultSeason,
    );
    final currentImageIndex = indices.imageIndices[dayOfWeek] ?? 0;
    String? imagePath;
    var nextImageIndex = 0;
    if (images.isNotEmpty) {
      final imageStep = QuoteSelector.getNextIndex(
        images.length,
        currentImageIndex,
      );
      imagePath = images[imageStep.currentIndex];
      nextImageIndex = imageStep.nextIndex;
    }

    await _indicesRepository.save(
      QuoteIndices(
        quoteIndices: {
          ...indices.quoteIndices,
          dayOfWeek: selectedText.nextIndex,
        },
        imageIndices: {...indices.imageIndices, dayOfWeek: nextImageIndex},
        lastDay: dayOfWeek,
        lastQuote: selectedText.text,
      ),
    );

    return Quote(
      text: selectedText.text,
      dayOfWeek: dayOfWeek,
      theme: dayData.theme,
      season: _defaultSeason,
      imagePath: imagePath,
    );
  }

  ({String text, int nextIndex}) _selectNonRepeatingText({
    required Map<String, DayQuotes> quotePool,
    required int dayOfWeek,
    required int currentIndex,
    required int nextIndex,
    required String? lastQuote,
    required String fallback,
  }) {
    var text = QuoteSelector.selectQuote(
      collection: quotePool,
      dayOfWeek: dayOfWeek,
      index: currentIndex,
    );
    var next = nextIndex;

    if (text != null && text == lastQuote) {
      final dayData = quotePool[dayOfWeek.toString()];
      final length = dayData?.quotes.length ?? 0;
      if (length <= 1) return (text: text, nextIndex: next);
      final nextStep = QuoteSelector.getNextIndex(length, next);
      text = QuoteSelector.selectQuote(
        collection: quotePool,
        dayOfWeek: dayOfWeek,
        index: next,
      );
      next = nextStep.nextIndex;
    }

    return (text: text ?? fallback, nextIndex: next);
  }

  int _dayOfWeek1to7(DateTime date) {
    // DateTime.weekday: Monday=1 ... Sunday=7
    // Iacula convention: Sunday=1 ... Saturday=7
    return (date.weekday % 7) + 1;
  }
}
