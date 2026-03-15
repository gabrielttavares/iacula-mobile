import '../../leituras/data/models/chapter_model.dart';
import '../domain/entities/reading_document_ref.dart';
import '../domain/entities/reading_text_block.dart';

ReadingDocumentRef mapLeiturasChapterToReadingDocument({
  required String bookId,
  required ChapterModel chapter,
}) {
  final blocks = <ReadingTextBlock>[
    ReadingTextBlock(
      id: 'chapter-title',
      text: chapter.title.trim(),
      type: ReadingTextBlockType.title,
    ),
  ];

  for (var index = 0; index < chapter.paragraphs.length; index++) {
    final paragraph = chapter.paragraphs[index].trim();
    if (paragraph.isEmpty) continue;
    blocks.add(
      ReadingTextBlock(
        id: 'intro-paragraph-$index',
        text: paragraph,
        type: ReadingTextBlockType.paragraph,
      ),
    );
  }

  for (var sectionIndex = 0; sectionIndex < chapter.sections.length; sectionIndex++) {
    final section = chapter.sections[sectionIndex];
    final heading = _headingForSection(section);
    if (heading.isNotEmpty) {
      blocks.add(
        ReadingTextBlock(
          id: 'section-$sectionIndex-heading',
          text: heading,
          type: ReadingTextBlockType.heading,
        ),
      );
    }

    for (var paragraphIndex = 0;
        paragraphIndex < section.paragraphs.length;
        paragraphIndex++) {
      final paragraph = section.paragraphs[paragraphIndex].trim();
      if (paragraph.isEmpty) continue;
      blocks.add(
        ReadingTextBlock(
          id: 'section-$sectionIndex-paragraph-$paragraphIndex',
          text: paragraph,
          type: ReadingTextBlockType.paragraph,
        ),
      );
    }
  }

  return ReadingDocumentRef(
    id: 'leituras:$bookId:${chapter.slug}',
    blocks: blocks,
  );
}

String _headingForSection(dynamic section) {
  final buffer = StringBuffer();
  if (section.number != null) {
    buffer.write('${section.number}.');
  }
  final title = section.title?.trim();
  if (title != null && title.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(title);
  }
  return buffer.toString();
}
