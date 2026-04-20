import '../../../liturgical/domain/liturgical_context.dart';
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

    final quotes = <Quote>[];
    final firstDate = startTime;
    final startDayOfWeek = _dayOfWeek1to7(firstDate);
    const context = LiturgicalContext.ordinaryFallback;

    final seasonalCollection = await _contentRepository.loadQuotes(
      language: language,
      season: context.season,
    );
    final quotePool = seasonalCollection;

    final imageLists = <int, List<String>>{};
    Future<List<String>> imagesForDay(int dow) async {
      final cached = imageLists[dow];
      if (cached != null) return cached;
      final list = await _contentRepository.listDayImages(
        dayOfWeek: dow,
        season: context.season,
      );
      imageLists[dow] = list;
      return list;
    }

    var indices = await _indicesRepository.load(dayOfWeek: startDayOfWeek);

    for (var i = 0; i < count; i++) {
      final quoteAt = startTime.add(
        Duration(minutes: intervalMinutes * (i + 1)),
      );
      final qDayOfWeek = _dayOfWeek1to7(quoteAt);
      final dayData = quotePool[qDayOfWeek.toString()];
      final seasonalImages = await imagesForDay(qDayOfWeek);

      if (dayData == null || dayData.quotes.isEmpty) {
        quotes.add(
          Quote(
            text: 'Conteudo indisponivel para hoje.',
            dayOfWeek: qDayOfWeek,
            theme: dayData?.theme ?? 'Sem tema',
            season: context.season,
          ),
        );
        continue;
      }

      final currentQuoteIndex = indices.quoteIndices[qDayOfWeek] ?? 0;
      final quoteStep = QuoteSelector.getNextIndex(
        dayData.quotes.length,
        currentQuoteIndex,
      );

      final currentImageIndex = indices.imageIndices[qDayOfWeek] ?? 0;
      String? imagePath;
      var nextImageIndex = 0;
      if (seasonalImages.isNotEmpty) {
        final imageStep = QuoteSelector.getNextIndex(
          seasonalImages.length,
          currentImageIndex,
        );
        imagePath = seasonalImages[imageStep.currentIndex];
        nextImageIndex = imageStep.nextIndex;
      }

      final text = QuoteSelector.selectQuote(
        collection: quotePool,
        dayOfWeek: qDayOfWeek,
        index: currentQuoteIndex,
      );

      var selectedText = text;
      var selectedIndex = quoteStep.nextIndex;

      // Prevent consecutive repeats
      if (selectedText != null && selectedText == indices.lastQuote) {
        // Advance index again to skip the repeat
        final nextStep = QuoteSelector.getNextIndex(
          dayData.quotes.length,
          selectedIndex,
        );
        selectedText = QuoteSelector.selectQuote(
          collection: quotePool,
          dayOfWeek: qDayOfWeek,
          index: selectedIndex,
        );
        selectedIndex = nextStep.nextIndex;
      }

      selectedText ??= dayData.quotes.first;

      indices = QuoteIndices(
        quoteIndices: {...indices.quoteIndices, qDayOfWeek: selectedIndex},
        imageIndices: {...indices.imageIndices, qDayOfWeek: nextImageIndex},
        lastDay: startDayOfWeek,
        lastQuote: selectedText,
      );

      quotes.add(
        Quote(
          text: selectedText,
          dayOfWeek: qDayOfWeek,
          theme: dayData.theme,
          season: context.season,
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
    const context = LiturgicalContext.ordinaryFallback;

    final seasonalCollection = await _contentRepository.loadQuotes(
      language: language,
      season: context.season,
    );

    final seasonalDay = seasonalCollection[dayOfWeek.toString()];
    final seasonalQuotes = seasonalDay?.quotes ?? const <String>[];

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
    final quoteStep = QuoteSelector.getNextIndex(
      dayData.quotes.length,
      currentQuoteIndex,
    );

    // TODO: re-enable feast images
    // final feastImagePath = context.feast == null ? null : await _contentRepository.getFeastImagePath(context.feast!);
    final seasonalImages = await _contentRepository.listDayImages(
      dayOfWeek: dayOfWeek,
      season: context.season,
    );
    final currentImageIndex = indices.imageIndices[dayOfWeek] ?? 0;

    String? imagePath;
    var nextImageIndex = 0;

    if (seasonalImages.isNotEmpty) {
      final imageStep = QuoteSelector.getNextIndex(
        seasonalImages.length,
        currentImageIndex,
      );
      imagePath = seasonalImages[imageStep.currentIndex];
      nextImageIndex = imageStep.nextIndex;
    }

    final text = QuoteSelector.selectQuote(
      collection: quotePool,
      dayOfWeek: dayOfWeek,
      index: currentQuoteIndex,
    );

    var selectedText = text;
    var selectedIndex = quoteStep.nextIndex;

    // Prevent consecutive repeats
    if (selectedText != null && selectedText == indices.lastQuote) {
      // Advance index again to skip the repeat
      final nextStep = QuoteSelector.getNextIndex(
        dayData.quotes.length,
        selectedIndex,
      );
      selectedText = QuoteSelector.selectQuote(
        collection: quotePool,
        dayOfWeek: dayOfWeek,
        index: selectedIndex,
      );
      selectedIndex = nextStep.nextIndex;
    }

    selectedText ??= seasonalQuotes.isNotEmpty
        ? seasonalQuotes.first
        : 'Conteudo indisponivel para hoje.';

    await _indicesRepository.save(
      QuoteIndices(
        quoteIndices: {...indices.quoteIndices, dayOfWeek: selectedIndex},
        imageIndices: {...indices.imageIndices, dayOfWeek: nextImageIndex},
        lastDay: dayOfWeek,
        lastQuote: selectedText,
      ),
    );

    return Quote(
      text: selectedText,
      dayOfWeek: dayOfWeek,
      theme: dayData.theme,
      season: context.season,
      imagePath: imagePath,
    );
  }

  int _dayOfWeek1to7(DateTime date) {
    // DateTime.weekday: Monday=1 ... Sunday=7
    // Iacula convention: Sunday=1 ... Saturday=7
    return (date.weekday % 7) + 1;
  }
}
