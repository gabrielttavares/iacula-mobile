abstract interface class DisabledQuotesRepository {
  Future<Set<int>> loadDisabledIndices({
    required int dayOfWeek,
    required String season,
  });

  Future<Map<int, Set<int>>> loadAllDisabled({required String season});

  Future<void> toggle({
    required int dayOfWeek,
    required int quoteIndex,
    required String season,
  });
}
