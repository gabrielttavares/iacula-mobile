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

  test('maps lent for holy week passion text even when color is vermelho', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Vermelho","liturgia":"6a feira da Semana Santa - Paixao do Senhor"}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final result = await service.getCurrentSeason(date: DateTime(2026, 4, 3));

    expect(result, LiturgicalSeason.lent);
  });

  test('canonicalizes pentecost feast slug from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Vermelho","liturgia":"Domingo de Pentecostes, Solenidade"}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 5, 24));

    expect(context.feast, 'pentecost');
  });

  test('canonicalizes long sao jose feast slug to st-joseph', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Branco","liturgia":"Sao Jose, Esposo da Bem-Aventurada Virgem Maria, Solenidade"}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 3, 19));

    expect(context.feast, 'st-joseph');
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

  test('detects palm sunday feast from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response('{"cor":"Vermelho","liturgia":"Domingo de Ramos, Festa"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 3, 29));

    expect(context.feast, 'palm-sunday');
  });

  test('detects holy thursday feast from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Branco","liturgia":"5a feira da Semana Santa - Missa vespertina da Ceia do Senhor"}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 4, 2));

    expect(context.feast, 'holy-thursday');
  });

  test('detects good friday feast from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Vermelho","liturgia":"6a feira da Semana Santa - Paixao do Senhor"}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 4, 3));

    expect(context.feast, 'good-friday');
  });

  test('detects easter vigil feast from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response('{"cor":"Branco","liturgia":"Vigilia Pascal, Solenidade"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 4, 4));

    expect(context.feast, 'easter-vigil');
  });

  test('detects easter sunday feast from liturgy title', () async {
    final client = MockClient((_) async {
      return http.Response('{"cor":"Branco","liturgia":"Domingo de Pascoa, Solenidade"}', 200);
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );
    final context = await service.getCurrentContext(date: DateTime(2026, 4, 5));

    expect(context.feast, 'easter-sunday');
  });
}
