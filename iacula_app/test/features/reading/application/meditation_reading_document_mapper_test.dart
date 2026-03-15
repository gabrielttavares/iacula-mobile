import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/reading/application/meditation_reading_document_mapper.dart';

void main() {
  test('meditation mapper builds stable document and block ids', () {
    final item = MeditationItem(
      id: 'med-1',
      type: MeditationType.text,
      title: 'Meditação do dia',
      summary: 'Resumo breve',
      categoryTags: const ['espiritual'],
      sourceName: 'Fonte',
      availability: const MeditationAvailability(
        kind: MeditationAvailabilityKind.evergreen,
      ),
      provenance: const MeditationProvenance(
        providerId: 'source',
        providerType: 'daily_text',
      ),
      textContent: const MeditationTextContent(
        body: 'Primeiro parágrafo.\n\nSegundo parágrafo.',
        format: 'plain',
        language: 'pt',
        sections: [
          MeditationTextSection(
            heading: 'Primeira seção',
            body: 'Texto da seção.\n\nOutro trecho.',
          ),
        ],
      ),
    );

    final document = mapMeditationToReadingDocument(item);

    expect(document.id, 'meditation:med-1');
    expect(
      document.blocks.map((block) => block.id),
      [
        'summary',
        'section-0-heading',
        'section-0-paragraph-0',
        'section-0-paragraph-1',
      ],
    );

    final repeated = mapMeditationToReadingDocument(item);
    expect(repeated.blocks.map((block) => block.id), document.blocks.map((block) => block.id));
  });
}
