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
  test('returns context with rank feast and api quotes', () async {
    final client = MockClient((_) async {
      return http.Response(
        '{"cor":"Branco","liturgia":"Solenidade de Todos os Santos","antifonas":{"entrada":"Antifona de entrada","comunhao":"Antifona de comunhao"},"leituras":{"salmo":[{"refrao":"Refrao do salmo"}]},"oracoes":{"coleta":"Oracao da coleta"}}',
        200,
      );
    });

    final service = RemoteLiturgicalSeasonService(
      httpClient: client,
      cacheRepository: _InMemoryCache(),
      baseUrl: 'https://example.com/v2',
    );

    final context = await service.getCurrentContext(date: DateTime(2026, 11, 1));

    expect(context.rank.name, 'solemnity');
    expect(context.feastName, 'todos os santos');
    expect(context.feast, 'all-saints');
    expect(context.apiQuotes, contains('Antifona de entrada'));
    expect(context.apiQuotes, contains('Refrao do salmo'));
  });

  test('canonicalizes pentecost context slug and preserves feast name', () async {
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

    expect(context.rank.name, 'solemnity');
    expect(context.feast, 'pentecost');
    expect(context.feastName, 'domingo de pentecostes');
  });
}
