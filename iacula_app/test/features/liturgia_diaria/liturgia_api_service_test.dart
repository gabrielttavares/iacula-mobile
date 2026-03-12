import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/infrastructure/services/liturgia_api_service.dart';

void main() {
  test('fetchPeriod parses period payload into domain entities', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-02-22","liturgia":"7o Domingo do Tempo Comum","cor":"Verde","oracoes":{"coleta":"Oracao da coleta","oferendas":"Oracao das oferendas","comunhao":"Oracao da comunhao","extras":["Oracao final"]},"antifonas":{"entrada":"Antifona de entrada","comunhao":"Antifona de comunhao"},"leituras":{"primeiraLeitura":{"referencia":"1Sm 1,1-10","titulo":"Primeira leitura","texto":"Texto 1"},"salmo":[{"referencia":"Sl 1","texto":"Texto do salmo","refrao":"Refrao do salmo"}],"evangelho":{"referencia":"Jo 1,1-5","titulo":"Evangelho","texto":"Texto 2"}}}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 7);

    expect(result, hasLength(1));
    final day = result.first;
    expect(day.date, DateTime(2026, 2, 22));
    expect(day.color.name, 'green');
    expect(day.prayers.collect, 'Oracao da coleta');
    expect(day.prayers.extra, contains('Oracao final'));
    expect(day.antiphons.entry, 'Antifona de entrada');
    expect(day.readings, hasLength(3));
    // Canonical order: first, psalm, gospel
    expect(day.readings[0].kind, LiturgyReadingKind.first);
    expect(day.readings[1].kind, LiturgyReadingKind.psalm);
    expect(day.readings[1].response, 'Refrao do salmo');
    expect(day.readings[2].kind, LiturgyReadingKind.gospel);
  });

  test('fetchPeriod returns empty list when response is non-success', () async {
    final client = MockClient(
      (_) async => http.Response('{"error":"oops"}', 500),
    );

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 7);

    expect(result, isEmpty);
  });

  test(
    'fetchPeriod derives sequential dates when payload lacks explicit dates',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          '[{"liturgia":"Dia 1","cor":"Verde","oracoes":{"coleta":"Coleta 1"},"leituras":[]},{"liturgia":"Dia 2","cor":"Vermelho","oracoes":{"coleta":"Coleta 2"},"leituras":[]},{"liturgia":"Dia 3","cor":"Branco","oracoes":{"coleta":"Coleta 3"},"leituras":[]}]',
          200,
        );
      });

      final service = LiturgiaApiService(
        httpClient: client,
        baseUrl: 'https://example.com/v2',
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final result = await service.fetchPeriod(days: 3);

      expect(result, hasLength(3));
      expect(result[0].date, today);
      expect(result[1].date, today.add(const Duration(days: 1)));
      expect(result[2].date, today.add(const Duration(days: 2)));
    },
  );

  test('fetchPeriod respects explicit dates when provided in payload', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-02-20","liturgia":"First","cor":"Verde","oracoes":{"coleta":"C"},"leituras":[]},{"data":"2026-02-22","liturgia":"Third","cor":"Branco","oracoes":{"coleta":"C"},"leituras":[]}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 2);

    expect(result, hasLength(2));
    expect(result[0].date, DateTime(2026, 2, 20));
    expect(result[1].date, DateTime(2026, 2, 22));
  });

  test('fetchPeriod parses dd/MM/yyyy dates from upstream payload', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"12/03/2026","liturgia":"5a feira da 3a Semana da Quaresma","cor":"Roxo","oracoes":{"coleta":"C"},"leituras":[]}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 1);

    expect(result, hasLength(1));
    expect(result.first.date, DateTime(2026, 3, 12));
  });

  test('fetchByDate keeps the requested date when upstream uses dd/MM/yyyy', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['dia'], '18');
      expect(request.url.queryParameters['mes'], '03');
      expect(request.url.queryParameters['ano'], '2026');

      return http.Response(
        '[{"data":"18/03/2026","liturgia":"4a feira da 4a Semana da Quaresma","cor":"Roxo","oracoes":{"coleta":"C"},"leituras":[]}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchByDate(DateTime(2026, 3, 18));

    expect(result, isNotNull);
    expect(result!.date, DateTime(2026, 3, 18));
  });

  test(
    'fetchByDate normalizes malformed upstream dates back to the requested day',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          '[{"data":"not-a-date","liturgia":"Dia pedido","cor":"Verde","oracoes":{"coleta":"C"},"leituras":[]}]',
          200,
        );
      });

      final service = LiturgiaApiService(
        httpClient: client,
        baseUrl: 'https://example.com/v2',
      );

      final result = await service.fetchByDate(DateTime(2026, 3, 18));

      expect(result, isNotNull);
      expect(result!.date, DateTime(2026, 3, 18));
    },
  );

  test('parses map-shaped leituras with full set and canonical order', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-03-01","liturgia":"Dia","cor":"Verde","oracoes":{"coleta":"C"},"antifonas":{},"leituras":{"primeiraLeitura":{"referencia":"Gn 1,1","texto":"Texto primeira"},"salmo":[{"referencia":"Sl 22","texto":"Texto salmo","refrao":"O Senhor é meu pastor"}],"segundaLeitura":{"referencia":"Rm 8,1","texto":"Texto segunda"},"sequencia":{"texto":"Texto sequencia"},"aclamacao":{"texto":"Aleluia","resposta":"Resposta aclamacao"},"evangelho":{"referencia":"Mt 5,1","texto":"Texto evangelho"}}}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 1);
    final readings = result.first.readings;

    expect(readings, hasLength(6));
    expect(readings[0].kind, LiturgyReadingKind.first);
    expect(readings[1].kind, LiturgyReadingKind.psalm);
    expect(readings[2].kind, LiturgyReadingKind.second);
    expect(readings[3].kind, LiturgyReadingKind.sequence);
    expect(readings[4].kind, LiturgyReadingKind.acclamation);
    expect(readings[5].kind, LiturgyReadingKind.gospel);

    // Psalm response preserved
    expect(readings[1].response, 'O Senhor é meu pastor');
    // Acclamation response preserved
    expect(readings[4].response, 'Resposta aclamacao');

    // Fallback titles for entries without titulo
    expect(readings[3].title, 'Sequência');
    expect(readings[4].title, 'Aclamação ao Evangelho');
  });

  test('parses list-shaped leituras with aliases and canonical order', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-03-02","liturgia":"Dia","cor":"Verde","oracoes":{"coleta":"C"},"antifonas":{},"leituras":[{"tipo":"evangelho","referencia":"Mc 1,1","texto":"Texto gospel"},{"tipo":"salmo","referencia":"Sl 50","texto":"Texto psalm","refrao":"Refrao"},{"tipo":"primeiraLeitura","referencia":"Is 1,1","titulo":"1a Leitura","texto":"Texto first"}]}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 1);
    final readings = result.first.readings;

    expect(readings, hasLength(3));
    // Canonical order despite list order being gospel, psalm, first
    expect(readings[0].kind, LiturgyReadingKind.first);
    expect(readings[0].title, '1a Leitura');
    expect(readings[1].kind, LiturgyReadingKind.psalm);
    expect(readings[1].response, 'Refrao');
    expect(readings[2].kind, LiturgyReadingKind.gospel);
  });

  test('uses fallback titles when titulo is missing', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-03-03","liturgia":"Dia","cor":"Verde","oracoes":{"coleta":"C"},"antifonas":{},"leituras":{"primeiraLeitura":{"referencia":"Gn 1","texto":"T"},"salmo":[{"texto":"T","refrao":"R"}],"evangelho":{"texto":"T"}}}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 1);
    final readings = result.first.readings;

    expect(readings[0].title, 'Primeira leitura'); // kind fallback for first
    expect(readings[1].title, 'Salmo'); // kind fallback for psalm
    expect(readings[2].title, 'Evangelho'); // kind fallback for gospel
  });

  test('ignores empty reading nodes', () async {
    final client = MockClient((_) async {
      return http.Response(
        '[{"data":"2026-03-04","liturgia":"Dia","cor":"Verde","oracoes":{"coleta":"C"},"antifonas":{},"leituras":{"primeiraLeitura":{"referencia":"","texto":"","titulo":""},"evangelho":{"referencia":"Jo 1","texto":"T"}}}]',
        200,
      );
    });

    final service = LiturgiaApiService(
      httpClient: client,
      baseUrl: 'https://example.com/v2',
    );

    final result = await service.fetchPeriod(days: 1);
    final readings = result.first.readings;

    expect(readings, hasLength(1));
    expect(readings[0].kind, LiturgyReadingKind.gospel);
  });
}
