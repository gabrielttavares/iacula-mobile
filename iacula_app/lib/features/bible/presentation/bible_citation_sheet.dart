import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/bible_citation.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/bible_verse.dart';
import '../domain/repositories/bible_repository.dart';
import 'bible_chapter_screen.dart';

/// Opens a footnote-style sheet with the verses of [citation], like tapping a
/// footnote in an e-reader, with a shortcut to the whole chapter.
Future<void> showBibleCitationSheet(
  BuildContext context,
  BibleCitation citation,
) {
  HapticFeedback.selectionClick();
  return IaculaModal.showSheet<void>(
    context: context,
    maxHeightFraction: 0.7,
    builder: (_) => BibleCitationSheet(citation: citation),
  );
}

typedef ResolvedBibleCitation = ({
  BibleBook book,
  BibleReference reference,
  List<BibleVerse> verses,
});

/// Resolves [citation] against the bundled Bible: picks the candidate reading
/// that exists and returns the cited verses (empty when the chapter exists but
/// the verse is missing from this translation). `null` when no book matches.
Future<ResolvedBibleCitation?> resolveBibleCitation(
  BibleRepository repository,
  BibleCitation citation,
) async {
  final books = await repository.listBooks();
  final chapters = <(String, int), List<BibleVerse>>{};
  for (final c in citation.candidates) {
    chapters[(c.bookAbbrev, c.chapter)] ??= await repository.getChapter(
      bookAbbrev: c.bookAbbrev,
      chapterNumber: c.chapter,
    );
  }

  final reference = citation.resolve((book, chapter) {
    final verses = chapters[(book, chapter)] ?? const <BibleVerse>[];
    return verses.fold(0, (max, v) => v.number > max ? v.number : max);
  });

  final book = books.where((b) => b.abbrev == reference.bookAbbrev).firstOrNull;
  if (book == null) return null;

  final chapter = chapters[(reference.bookAbbrev, reference.chapter)] ?? const [];
  return (
    book: book,
    reference: reference,
    verses: [
      for (final v in chapter)
        if (reference.containsVerse(v.number)) v,
    ],
  );
}

class BibleCitationSheet extends ConsumerStatefulWidget {
  const BibleCitationSheet({super.key, required this.citation});

  final BibleCitation citation;

  @override
  ConsumerState<BibleCitationSheet> createState() => _BibleCitationSheetState();
}

class _BibleCitationSheetState extends ConsumerState<BibleCitationSheet> {
  late final Future<ResolvedBibleCitation?> _resolved = resolveBibleCitation(
    ref.read(bibleRepositoryProvider),
    widget.citation,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResolvedBibleCitation?>(
      future: _resolved,
      builder: (context, snapshot) {
        final resolved = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            IaculaSpacing.lg,
            IaculaSpacing.sm,
            IaculaSpacing.lg,
            IaculaSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.colors.separator,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: IaculaSpacing.md),
              Text(
                resolved == null
                    ? widget.citation.label
                    : _title(resolved.book, resolved.reference),
                style: context.textStyles.cardTitle,
              ),
              const SizedBox(height: IaculaSpacing.md),
              Flexible(child: _body(context, loading, resolved)),
              if (resolved != null) ...[
                const SizedBox(height: IaculaSpacing.lg),
                IaculaPrimaryPillButton(
                  label: 'Ler capítulo completo',
                  onPressed: () => _openChapter(resolved),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    bool loading,
    ResolvedBibleCitation? resolved,
  ) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: IaculaSpacing.lg),
        child: CupertinoActivityIndicator(),
      );
    }
    if (resolved == null || resolved.verses.isEmpty) {
      return Text(
        resolved == null
            ? 'Não encontramos esta passagem na Bíblia do app.'
            : 'Este versículo não consta nesta tradução. '
                  'Abra o capítulo para ler o contexto.',
        style: context.textStyles.secondary,
      );
    }

    final body = context.textStyles.readingBody;
    final number = context.textStyles.secondary.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: context.colors.primaryButton,
    );
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Text.rich(
        TextSpan(
          style: body,
          children: [
            for (var i = 0; i < resolved.verses.length; i++) ...[
              if (i > 0) const TextSpan(text: '  '),
              TextSpan(text: '${resolved.verses[i].number} ', style: number),
              TextSpan(text: resolved.verses[i].text),
            ],
          ],
        ),
      ),
    );
  }

  String _title(BibleBook book, BibleReference reference) {
    if (reference.isWholeChapter) return '${book.name} ${reference.chapter}';
    return '${book.name} ${reference.chapter}, ${reference.verses.join('.')}';
  }

  void _openChapter(ResolvedBibleCitation resolved) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => BibleChapterScreen(
          book: resolved.book,
          chapterNumber: resolved.reference.chapter,
          focus: resolved.reference,
        ),
      ),
    );
  }
}
