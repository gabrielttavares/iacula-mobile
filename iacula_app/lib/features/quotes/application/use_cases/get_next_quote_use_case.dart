import 'dart:convert';

import '../../../custom_phrases/domain/repositories/custom_phrase_repository.dart';
import '../../../liturgical/domain/liturgical_season.dart';
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
  }) : _contentRepository = contentRepository,
       _indicesRepository = indicesRepository,
       _disabledQuotesRepository = disabledQuotesRepository,
       _customPhraseRepository = customPhraseRepository;

  final QuoteContentRepository _contentRepository;
  final QuoteIndicesRepository _indicesRepository;
  final DisabledQuotesRepository _disabledQuotesRepository;
  final CustomPhraseRepository _customPhraseRepository;

  Future<Quote> call({required String language, DateTime? now}) async {
    final date = now ?? DateTime.now();
    final dayOfWeek = _dayOfWeek1to7(date);
    const season = LiturgicalSeason.ordinary;

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
    final quotePoolKey = _poolKeyFor(effectiveQuotes);
    final quoteSelection = QuoteSelector.selectFromShuffleBag(
      effectiveQuotes,
      cursor: indices.quoteIndices[dayOfWeek] ?? 0,
      order: indices.quoteOrders[dayOfWeek],
      currentPoolKey: indices.quotePoolKeys[dayOfWeek],
      nextPoolKey: quotePoolKey,
    );

    final seasonalImages = await _contentRepository.listDayImages(
      dayOfWeek: dayOfWeek,
      season: season,
    );
    final imagePoolKey = _poolKeyFor(seasonalImages);

    String? imagePath;
    List<int>? nextImageOrder;
    var nextImageCursor = 0;

    if (seasonalImages.isNotEmpty) {
      final imageSelection = QuoteSelector.selectFromShuffleBag(
        seasonalImages,
        cursor: indices.imageIndices[dayOfWeek] ?? 0,
        order: indices.imageOrders[dayOfWeek],
        currentPoolKey: indices.imagePoolKeys[dayOfWeek],
        nextPoolKey: imagePoolKey,
      );
      imagePath = imageSelection.item;
      nextImageOrder = imageSelection.nextOrder;
      nextImageCursor = imageSelection.nextCursor;
    }
    final selectedText =
        quoteSelection.item ??
        (effectiveQuotes.isNotEmpty
            ? effectiveQuotes.first
            : 'Conteudo indisponivel para hoje.');

    await _indicesRepository.save(
      QuoteIndices(
        quoteIndices: {
          ...indices.quoteIndices,
          dayOfWeek: quoteSelection.nextCursor,
        },
        imageIndices: {...indices.imageIndices, dayOfWeek: nextImageCursor},
        quoteOrders: {
          ...indices.quoteOrders,
          dayOfWeek: quoteSelection.nextOrder,
        },
        imageOrders: {
          ...indices.imageOrders,
          if (nextImageOrder != null) dayOfWeek: nextImageOrder,
        },
        quotePoolKeys: {...indices.quotePoolKeys, dayOfWeek: quotePoolKey},
        imagePoolKeys: {
          ...indices.imagePoolKeys,
          if (seasonalImages.isNotEmpty) dayOfWeek: imagePoolKey,
        },
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

  int _dayOfWeek1to7(DateTime date) {
    return (date.weekday % 7) + 1;
  }

  String _poolKeyFor(List<String> values) {
    return jsonEncode(values);
  }
}
