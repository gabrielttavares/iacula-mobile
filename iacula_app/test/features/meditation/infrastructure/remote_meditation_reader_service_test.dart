import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/infrastructure/services/remote_meditation_reader_service.dart';

void main() {
  final service = RemoteMeditationReaderService(httpClient: http.Client());

  MeditationItem buildItem(String providerId) {
    return MeditationItem(
      id: providerId,
      type: MeditationType.text,
      title: 'Teste',
      summary: 'Resumo',
      categoryTags: const ['espiritual'],
      sourceName: 'Fonte',
      sourceUrl: 'https://example.com',
      availability: const MeditationAvailability(
        kind: MeditationAvailabilityKind.daily,
      ),
      provenance: MeditationProvenance(
        providerId: providerId,
        providerType: 'daily_text',
      ),
    );
  }

  test('parse extracts hablar content paragraphs', () {
    const html = '''
      <html><body>
        <div class="entry-content">
          <figure>ignore</figure>
          <p>Primeiro parágrafo.</p>
          <p>Segundo parágrafo.</p>
        </div>
      </body></html>
    ''';

    final content = service.parse(buildItem('hablar-con-dios'), html);

    expect(content, isNotNull);
    expect(content!.body, contains('Primeiro parágrafo.'));
    expect(content.body, contains('Segundo parágrafo.'));
  });

  test('parse extracts ibreviary reading sections', () {
    const html = '''
      <html><body>
        <div id="contenuto"><div class="inner">
          <p><span class="capolettera_piccolo">READINGS</span><br /><br />
          <span class="rubrica">FIRST READING</span><br /><br />Texto um.<br /><br />
          <span class="rubrica">SECOND READING</span><br /><br />Texto dois.<br /><br />
          <span class="capolettera_piccolo">ACCLAMATION</span><br /><br />Fim.</p>
          <p>******</p>
        </div></div>
      </body></html>
    ''';

    final content = service.parse(buildItem('ibreviary'), html);

    expect(content, isNotNull);
    expect(content!.sections, isNotEmpty);
    expect(content.sections!.first.heading, 'FIRST READING');
    expect(content.sections!.first.body, contains('Texto um.'));
  });

  test('parse extracts meditatione daily sections from next data', () {
    const html = '''
      <html><body>
        <script id="__NEXT_DATA__" type="application/json">
        {
          "props": {
            "pageProps": {
              "meditationsExt": [
                {
                  "meditation": {
                    "title": "A Paixão de Cristo",
                    "subTitle": "Quinta-feira"
                  },
                  "book": {
                    "language": "pt",
                    "shortDescription": "Descrição curta do livro.",
                    "text": "Texto longo com [fonte](https://example.com)."
                  },
                  "author": {
                    "name": "São Tomás de Aquino"
                  }
                }
              ]
            }
          }
        }
        </script>
      </body></html>
    ''';

    final content = service.parse(buildItem('meditatione'), html);

    expect(content, isNotNull);
    expect(content!.sections, hasLength(1));
    expect(content.sections!.first.heading, 'A Paixão de Cristo');
    expect(content.sections!.first.body, contains('São Tomás de Aquino'));
    expect(content.sections!.first.body, isNot(contains('[fonte]')));
  });
}
