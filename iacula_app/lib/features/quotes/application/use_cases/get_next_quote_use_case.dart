import '../../../custom_phrases/domain/repositories/custom_phrase_repository.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../../liturgical/domain/services/liturgical_season_service.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/disabled_quotes_repository.dart';
import '../../domain/repositories/quote_content_repository.dart';
import '../../domain/repositories/quote_indices_repository.dart';
import '../../domain/services/quote_selector.dart';

final class GetNextQuoteUseCase {
  const GetNextQuoteUseCase({
    required QuoteContentRepository contentRepository,
    required QuoteIndicesRepository indicesRepository,
    required DisabledQuotesRepository disabledQuotesRepository,
    required CustomPhraseRepository customPhraseRepository,
    LiturgicalSeasonService? liturgicalSeasonService,
  }) : _contentRepository = contentRepository,
       _indicesRepository = indicesRepository,
       _disabledQuotesRepository = disabledQuotesRepository,
       _customPhraseRepository = customPhraseRepository,
       _liturgicalSeasonService = liturgicalSeasonService;

  final QuoteContentRepository _contentRepository;
  final QuoteIndicesRepository _indicesRepository;
  final DisabledQuotesRepository _disabledQuotesRepository;
  final CustomPhraseRepository _customPhraseRepository;
  final LiturgicalSeasonService? _liturgicalSeasonService;

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
    final season = await _resolveSeason(firstDate);

    final seasonalCollection = await _contentRepository.loadQuotes(
      language: language,
      season: season,
    );
    final quotePool = seasonalCollection;
    final seasonName = season.name;

    final imageLists = <int, List<String>>{};
    Future<List<String>> imagesForDay(int dow) async {
      final cached = imageLists[dow];
      if (cached != null) return cached;
      final list = await _contentRepository.listDayImages(
        dayOfWeek: dow,
        season: season,
      );
      imageLists[dow] = list;
      return list;
    }

    final rotationPhrases = await _loadRotationPhrases();

    final disabledCache = <int, Set<int>>{};
    Future<List<String>> enabledQuotesForDay(int dow, List<String> all) async {
      final disabled = disabledCache[dow] ??=
          await _disabledQuotesRepository.loadDisabledIndices(
            dayOfWeek: dow,
            season: seasonName,
          );
      final base = disabled.isEmpty
          ? all
          : [
              for (var i = 0; i < all.length; i++)
                if (!disabled.contains(i)) all[i],
            ];
      final filtered = (base.isEmpty ? all : base) + rotationPhrases;
      return filtered;
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
            season: season,
          ),
        );
        continue;
      }

      final enabled = await enabledQuotesForDay(qDayOfWeek, dayData.quotes);

      final currentQuoteIndex = indices.quoteIndices[qDayOfWeek] ?? 0;
      final quoteStep = QuoteSelector.getNextIndex(
        enabled.length,
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

      var selectedText = QuoteSelector.selectFromList(
        enabled,
        currentQuoteIndex,
      );
      var selectedIndex = quoteStep.nextIndex;

      if (selectedText != null && selectedText == indices.lastQuote) {
        final nextStep = QuoteSelector.getNextIndex(
          enabled.length,
          selectedIndex,
        );
        selectedText = QuoteSelector.selectFromList(enabled, selectedIndex);
        selectedIndex = nextStep.nextIndex;
      }

      selectedText ??= enabled.first;

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
          season: season,
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
    final season = await _resolveSeason(date);

    final seasonalCollection = await _contentRepository.loadQuotes(
      language: language,
      season: season,
    );

    final dayData = seasonalCollection[dayOfWeek.toString()];
    if (dayData == null || dayData.quotes.isEmpty) {
      return Quote(
        text: 'Conteudo indisponivel para hoje.',
        dayOfWeek: dayOfWeek,
        theme: dayData?.theme ?? 'Sem tema',
        season: season,
      );
    }

    final disabled = await _disabledQuotesRepository.loadDisabledIndices(
      dayOfWeek: dayOfWeek,
      season: season.name,
    );
    final enabled = disabled.isEmpty
        ? dayData.quotes
        : [
            for (var i = 0; i < dayData.quotes.length; i++)
              if (!disabled.contains(i)) dayData.quotes[i],
          ];
    final rotationPhrases = await _loadRotationPhrases();
    final effectiveQuotes =
        (enabled.isEmpty ? dayData.quotes : enabled) + rotationPhrases;

    final indices = await _indicesRepository.load(dayOfWeek: dayOfWeek);
    final currentQuoteIndex = indices.quoteIndices[dayOfWeek] ?? 0;
    final quoteStep = QuoteSelector.getNextIndex(
      effectiveQuotes.length,
      currentQuoteIndex,
    );

    final seasonalImages = await _contentRepository.listDayImages(
      dayOfWeek: dayOfWeek,
      season: season,
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

    var selectedText = QuoteSelector.selectFromList(
      effectiveQuotes,
      currentQuoteIndex,
    );
    var selectedIndex = quoteStep.nextIndex;

    if (selectedText != null && selectedText == indices.lastQuote) {
      final nextStep = QuoteSelector.getNextIndex(
        effectiveQuotes.length,
        selectedIndex,
      );
      selectedText = QuoteSelector.selectFromList(
        effectiveQuotes,
        selectedIndex,
      );
      selectedIndex = nextStep.nextIndex;
    }

    selectedText ??= effectiveQuotes.isNotEmpty
        ? effectiveQuotes.first
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
      season: season,
      imagePath: imagePath,
    );
  }

  Future<List<String>> _loadRotationPhrases() async {
    final allPhrases = await _customPhraseRepository.listAll();
    return [
      for (final p in allPhrases)
        if (p.isActive && p.isRotationMode) p.text,
    ];
  }

  Future<LiturgicalSeason> _resolveSeason(DateTime date) async {
    if (_liturgicalSeasonService != null) {
      try {
        return await _liturgicalSeasonService.getCurrentSeason(date: date);
      } catch (_) {
        // Fall through to default on any error.
      }
    }
    return LiturgicalSeason.ordinary;
  }

  int _dayOfWeek1to7(DateTime date) {
    // DateTime.weekday: Monday=1 ... Sunday=7
    // Iacula convention: Sunday=1 ... Saturday=7
    return (date.weekday % 7) + 1;
  }
}
