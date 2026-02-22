import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/features/liturgia_diaria/infrastructure/repositories/liturgia_cache_repository.dart';
import 'package:iacula_app/features/liturgia_diaria/infrastructure/services/liturgia_api_service.dart';

void main() {
  test('uses cache while period is fresh', () async {
    var calls = 0;
    var now = DateTime(2026, 2, 22, 10);
    final client = MockClient((_) async {
      calls++;
      return http.Response(
        '[{"data":"2026-02-22","liturgia":"Domingo","cor":"Verde","oracoes":{},"antifonas":{},"leituras":{}}]',
        200,
      );
    });

    final repo = LiturgiaCacheRepository(
      apiService: LiturgiaApiService(
        httpClient: client,
        baseUrl: 'https://example.com/v2',
      ),
      now: () => now,
    );

    await repo.getLiturgyPeriod(7);
    now = now.add(const Duration(hours: 1));
    await repo.getLiturgyPeriod(7);

    expect(calls, 1);
  });

  test('refreshes cache when stale', () async {
    var calls = 0;
    var now = DateTime(2026, 2, 22, 10);
    final client = MockClient((_) async {
      calls++;
      return http.Response(
        '[{"data":"2026-02-22","liturgia":"Domingo","cor":"Verde","oracoes":{},"antifonas":{},"leituras":{}}]',
        200,
      );
    });

    final repo = LiturgiaCacheRepository(
      apiService: LiturgiaApiService(
        httpClient: client,
        baseUrl: 'https://example.com/v2',
      ),
      now: () => now,
    );

    await repo.getLiturgyPeriod(7);
    now = now.add(const Duration(hours: 7));
    await repo.getLiturgyPeriod(7);

    expect(calls, 2);
  });
}
