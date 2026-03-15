import '../../meditation/domain/entities/meditation_item.dart';
import '../domain/entities/reading_document_ref.dart';
import '../domain/entities/reading_text_block.dart';

ReadingDocumentRef mapMeditationToReadingDocument(MeditationItem item) {
  final blocks = <ReadingTextBlock>[];
  final content = item.textContent;
  if (item.summary.trim().isNotEmpty) {
    blocks.add(
      ReadingTextBlock(
        id: 'summary',
        text: item.summary.trim(),
        type: ReadingTextBlockType.summary,
      ),
    );
  }

  if (content == null) {
    return ReadingDocumentRef(id: 'meditation:${item.id}', blocks: blocks);
  }

  final sections = content.sections ?? const <MeditationTextSection>[];
  if (sections.isEmpty) {
    final paragraphs = _splitParagraphs(content.body);
    for (var index = 0; index < paragraphs.length; index++) {
      blocks.add(
        ReadingTextBlock(
          id: 'body-paragraph-$index',
          text: paragraphs[index],
          type: ReadingTextBlockType.paragraph,
        ),
      );
    }
    return ReadingDocumentRef(id: 'meditation:${item.id}', blocks: blocks);
  }

  for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
    final section = sections[sectionIndex];
    final heading = section.heading.trim();
    if (heading.isNotEmpty) {
      blocks.add(
        ReadingTextBlock(
          id: 'section-$sectionIndex-heading',
          text: heading,
          type: ReadingTextBlockType.heading,
        ),
      );
    }

    final paragraphs = _splitParagraphs(section.body);
    for (var paragraphIndex = 0;
        paragraphIndex < paragraphs.length;
        paragraphIndex++) {
      blocks.add(
        ReadingTextBlock(
          id: 'section-$sectionIndex-paragraph-$paragraphIndex',
          text: paragraphs[paragraphIndex],
          type: ReadingTextBlockType.paragraph,
        ),
      );
    }
  }

  return ReadingDocumentRef(id: 'meditation:${item.id}', blocks: blocks);
}

List<String> _splitParagraphs(String text) {
  return text
      .split(RegExp(r'\n{2,}'))
      .map((paragraph) => paragraph.trim())
      .where((paragraph) => paragraph.isNotEmpty)
      .toList(growable: false);
}
