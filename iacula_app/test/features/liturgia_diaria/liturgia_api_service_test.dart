import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
    expect(day.readings[1].response, 'Refrao do salmo');
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

  test('fetchPeriod derives sequential dates when payload lacks explicit dates', () async {
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
  });

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
}
