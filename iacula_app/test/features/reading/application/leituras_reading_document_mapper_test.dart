import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/leituras/data/models/chapter_model.dart';
import 'package:iacula_app/features/leituras/data/models/reading_point_model.dart';
import 'package:iacula_app/features/reading/application/leituras_reading_document_mapper.dart';

void main() {
  test('leituras mapper builds stable document and block ids', () {
    const chapter = ChapterModel(
      slug: 'carater',
      title: 'Caráter',
      kind: 'points',
      paragraphs: ['Parágrafo de abertura.'],
      sections: [
        ReadingPointModel(number: 1, title: 'Ponto', paragraphs: ['Texto 1', 'Texto 2']),
      ],
    );

    final document = mapLeiturasChapterToReadingDocument(
      bookId: 'caminho',
      chapter: chapter,
    );

    expect(document.id, 'leituras:caminho:carater');
    expect(
      document.blocks.map((block) => block.id),
      [
        'chapter-title',
        'intro-paragraph-0',
        'section-0-heading',
        'section-0-paragraph-0',
        'section-0-paragraph-1',
      ],
    );

    final repeated = mapLeiturasChapterToReadingDocument(
      bookId: 'caminho',
      chapter: chapter,
    );
    expect(repeated.blocks.map((block) => block.id), document.blocks.map((block) => block.id));
  });
}
