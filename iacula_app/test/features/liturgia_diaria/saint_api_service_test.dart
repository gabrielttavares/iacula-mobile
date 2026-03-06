import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/features/liturgia_diaria/infrastructure/services/saint_api_service.dart';

void main() {
  test('fetches today saint from api payload', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api-liturgia-diaria.vercel.app/santo-do-dia',
      );
      return http.Response(
        '{"today":{"title":"Santa Rosa de Viterbo","full_text":"Paragrafo 1\\n\\nParagrafo 2","image":"https://example.com/rosa.jpg"}}',
        200,
      );
    });

    final service = SaintApiService(httpClient: client);

    final result = await service.fetchTodaySaint();

    expect(result?.name, 'Santa Rosa de Viterbo');
    expect(result?.biographyParagraphs, ['Paragrafo 1', 'Paragrafo 2']);
    expect(result?.remoteImageUrl, 'https://example.com/rosa.jpg');
  });

  test('resolves saint page url from cancao nova calendar html', () async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/admin-ajax.php')) {
        return http.Response('''
          <div id="cn-calendar">
            <a href="https://santo.cancaonova.com/santo/santa-rosa-de-viterbo/?sDia=6&sMes=03&sAno=2026">06</a>
          </div>
          ''', 200);
      }
      throw AssertionError('Unexpected request: ${request.url}');
    });

    final service = SaintApiService(
      httpClient: client,
      cancaoNovaBaseUrl: 'https://santo.cancaonova.com',
    );

    final url = await service.resolveSaintPageUrl(DateTime(2026, 3, 6));

    expect(
      url,
      'https://santo.cancaonova.com/santo/santa-rosa-de-viterbo/?sDia=6&sMes=03&sAno=2026',
    );
  });

  test('parses saint page into name biography paragraphs and image', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://santo.cancaonova.com/santo/santa-rosa-de-viterbo/?sDia=6&sMes=03&sAno=2026',
      );
      return http.Response('''
        <html>
          <body>
            <h1 class="entry-title">Santa Rosa de Viterbo</h1>
            <div class="entry-content">
              <p><img src="https://img.cancaonova.com/rosa.jpg" /></p>
              <p>Primeiro paragrafo.</p>
              <p>Segundo paragrafo.</p>
            </div>
          </body>
        </html>
        ''', 200);
    });

    final service = SaintApiService(httpClient: client);

    final result = await service.fetchSaintFromPage(
      'https://santo.cancaonova.com/santo/santa-rosa-de-viterbo/?sDia=6&sMes=03&sAno=2026',
      date: DateTime(2026, 3, 6),
    );

    expect(result?.name, 'Santa Rosa de Viterbo');
    expect(result?.biographyParagraphs, [
      'Primeiro paragrafo.',
      'Segundo paragrafo.',
    ]);
    expect(result?.remoteImageUrl, 'https://img.cancaonova.com/rosa.jpg');
  });
}
