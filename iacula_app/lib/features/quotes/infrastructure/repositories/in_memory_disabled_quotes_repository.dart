import '../../domain/repositories/disabled_quotes_repository.dart';

final class InMemoryDisabledQuotesRepository
    implements DisabledQuotesRepository {
  final _store = <String, Set<int>>{};

  String _key(int dayOfWeek, String season) => '$dayOfWeek:$season';

  @override
  Future<Set<int>> loadDisabledIndices({
    required int dayOfWeek,
    required String season,
  }) async {
    return Set.unmodifiable(_store[_key(dayOfWeek, season)] ?? const <int>{});
  }

  @override
  Future<Map<int, Set<int>>> loadAllDisabled({required String season}) async {
    final result = <int, Set<int>>{};
    for (final entry in _store.entries) {
      if (entry.key.endsWith(':$season')) {
        final day = int.parse(entry.key.split(':').first);
        result[day] = Set.unmodifiable(entry.value);
      }
    }
    return result;
  }

  @override
  Future<void> toggle({
    required int dayOfWeek,
    required int quoteIndex,
    required String season,
  }) async {
    final key = _key(dayOfWeek, season);
    final set = _store[key] ??= <int>{};
    if (!set.remove(quoteIndex)) {
      set.add(quoteIndex);
    }
  }
}
