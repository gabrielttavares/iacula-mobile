import '../../domain/entities/daily_liturgy.dart';
import '../../domain/repositories/liturgia_repository.dart';
import '../services/liturgia_api_service.dart';

final class LiturgiaCacheRepository implements LiturgiaRepository {
  LiturgiaCacheRepository({
    required LiturgiaApiService apiService,
    this.cacheTtl = const Duration(hours: 6),
    DateTime Function()? now,
  }) : _apiService = apiService,
       _now = now ?? DateTime.now;

  final LiturgiaApiService _apiService;
  final Duration cacheTtl;
  final DateTime Function() _now;

  DateTime? _cachedAt;
  List<LiturgyDay> _cachedPeriod = const <LiturgyDay>[];

  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async {
    if (_isFresh()) {
      final cached = _findByDate(date, _cachedPeriod);
      if (cached != null) {
        return cached;
      }
    }

    final fetched = await _apiService.fetchByDate(date);
    if (fetched == null) return null;

    _upsertDay(fetched);
    return fetched;
  }

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int days) async {
    final safeDays = days.clamp(1, 7);
    if (_isFresh() && _cachedPeriod.isNotEmpty) {
      return _cachedPeriod.take(safeDays).toList(growable: false);
    }

    final fetched = await _apiService.fetchPeriod(days: safeDays);
    if (fetched.isNotEmpty) {
      _cachedPeriod = fetched;
      _cachedAt = _now();
      return fetched;
    }

    if (_isFresh()) {
      return _cachedPeriod.take(safeDays).toList(growable: false);
    }

    return const <LiturgyDay>[];
  }

  bool _isFresh() {
    final cachedAt = _cachedAt;
    if (cachedAt == null) return false;
    return _now().difference(cachedAt) <= cacheTtl;
  }

  LiturgyDay? _findByDate(DateTime date, List<LiturgyDay> source) {
    for (final day in source) {
      if (_sameDate(day.date, date)) return day;
    }
    return null;
  }

  void _upsertDay(LiturgyDay day) {
    final mutable = _cachedPeriod.toList(growable: true);
    final index = mutable.indexWhere((item) => _sameDate(item.date, day.date));
    if (index >= 0) {
      mutable[index] = day;
    } else {
      mutable.add(day);
      mutable.sort((a, b) => a.date.compareTo(b.date));
    }
    _cachedPeriod = mutable;
    _cachedAt = _now();
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
