import '../../domain/entities/saint_of_day.dart';
import '../../domain/repositories/saint_repository.dart';
import '../services/saint_api_service.dart';
import '../services/saint_image_resolver.dart';

final class SaintCacheRepository implements SaintRepository {
  SaintCacheRepository({
    required SaintApiService apiService,
    required SaintImageResolver imageResolver,
    DateTime Function()? now,
  }) : _apiService = apiService,
       _imageResolver = imageResolver,
       _now = now ?? DateTime.now;

  final SaintApiService _apiService;
  final SaintImageResolver _imageResolver;
  final DateTime Function() _now;
  final Map<String, SaintOfDay> _cache = <String, SaintOfDay>{};

  @override
  Future<SaintOfDay?> getSaintForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final key = _dateKey(normalized);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    SaintOfDay? saint;
    final today = _normalizeDate(_now());
    if (_sameDate(today, normalized)) {
      saint = await _apiService.fetchTodaySaint();
      saint = saint?.copyWith(date: normalized);
    } else {
      final pageUrl = await _apiService.resolveSaintPageUrl(normalized);
      if (pageUrl != null) {
        saint = await _apiService.fetchSaintFromPage(pageUrl, date: normalized);
      }
    }

    if (saint == null) return null;
    final resolved = await _imageResolver.resolve(saint);
    _cache[key] = resolved;
    return resolved;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
}
