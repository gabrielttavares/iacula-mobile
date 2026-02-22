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
}
