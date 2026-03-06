import '../../../leituras/data/repositories/leitura_repository.dart';
import '../../../liturgical/domain/liturgical_season.dart';
import '../../domain/entities/quote.dart';

final class GetNextEscrivaPointsQuoteUseCase {
  const GetNextEscrivaPointsQuoteUseCase(this._leituraRepository);

  final LeituraRepository _leituraRepository;

  static const _bookIds = <String>['caminho', 'sulco', 'forja'];

  Future<Quote> call({required String language, DateTime? now}) async {
    final date = now ?? DateTime.now();
    final dayOfWeek = (date.weekday % 7) + 1;
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final pool = <_EscrivaPoint>[];

    for (final bookId in _bookIds) {
      final book = await _leituraRepository.getBook(bookId);
      if (book == null) {
        continue;
      }

      final pointChapters = book.chapters.where(
        (chapter) => chapter.kind == 'points',
      );
      for (final chapter in pointChapters) {
        for (final section in chapter.sections) {
          final text = section.paragraphs
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .join('\n\n');
          if (text.isEmpty) {
            continue;
          }

          pool.add(
            _EscrivaPoint(
              text: text,
              theme: '${book.title} · ${chapter.title}',
              referenceLabel: section.number != null
                  ? '${book.title}, ${section.number}'
                  : '${book.title}, ${chapter.title}',
            ),
          );
        }
      }
    }

    if (pool.isEmpty) {
      return Quote(
        text: 'Conteudo indisponivel para hoje.',
        dayOfWeek: dayOfWeek,
        theme: 'Sem tema',
        season: LiturgicalSeason.ordinary,
      );
    }

    final selected = pool[dayOfYear % pool.length];
    return Quote(
      text: selected.text,
      dayOfWeek: dayOfWeek,
      theme: selected.theme,
      season: LiturgicalSeason.ordinary,
      source: QuoteSource.escrivaPoints,
      referenceLabel: selected.referenceLabel,
    );
  }
}

final class _EscrivaPoint {
  const _EscrivaPoint({
    required this.text,
    required this.theme,
    required this.referenceLabel,
  });

  final String text;
  final String theme;
  final String referenceLabel;
}
