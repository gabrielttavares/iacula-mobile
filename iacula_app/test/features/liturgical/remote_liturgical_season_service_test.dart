import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/repositories/liturgical_season_cache_repository.dart';
import 'package:iacula_app/features/liturgical/infrastructure/services/remote_liturgical_season_service.dart';

class _InMemoryCache implements LiturgicalSeasonCacheRepository {
  final Map<String, LiturgicalSeason> _map = {};

  @override
  Future<LiturgicalSeason?> getByDateKey(String dateKey) async => _map[dateKey];

  @override
  Future<void> put(String dateKey, LiturgicalSeason season) async {
    _map[dateKey] = season;
  }
}

void main() {
  test('maps advent from roxo + advento', () async {
    final client = MockClient((_) async {
      return http.Response('{"cor":"Roxo","liturgia":"1o Domingo do Advento"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final result = await service.getCurrentSeason(date: DateTime(2026, 12, 10));

    expect(result, LiturgicalSeason.advent);
  });

  test('maps easter from branco + pascoa', () async {
    final client = MockClient((_) async {
      return http.Response('{"cor":"Branco","liturgia":"Domingo de Pascoa"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final result = await service.getCurrentSeason(date: DateTime(2026, 4, 5));

    expect(result, LiturgicalSeason.easter);
  });

  test('fallbacks to ordinary when request fails', () async {
    final client = MockClient((_) async => throw Exception('network'));

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final result = await service.getCurrentSeason(date: DateTime(2026, 2, 18));

    expect(result, LiturgicalSeason.ordinary);
  });

  test('caches successful response per date', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('{"cor":"Roxo","liturgia":"Quaresma"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    await service.getCurrentSeason(date: DateTime(2026, 2, 18));
    await service.getCurrentSeason(date: DateTime(2026, 2, 18));

    expect(calls, 1);
  });
}
