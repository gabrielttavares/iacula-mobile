import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AdaptiveTextSelectionToolbar,
        ContextMenuButtonItem,
        EditableTextState,
        SelectableText,
        TextSpan;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../reading/domain/entities/reading_highlight.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/bible_chapter_ref.dart';
import '../domain/entities/bible_verse.dart';

class BibleChapterScreen extends ConsumerStatefulWidget {
  const BibleChapterScreen({
    super.key,
    required this.book,
    required this.chapterNumber,
  });

  final BibleBook book;
  final int chapterNumber;

  @override
  ConsumerState<BibleChapterScreen> createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends ConsumerState<BibleChapterScreen> {
  List<ReadingHighlight> _highlights = [];
  late final String _documentId;

  @override
  void initState() {
    super.initState();
    _documentId = 'bible:${widget.book.abbrev}:${widget.chapterNumber}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biblePrefsProvider.notifier).savePosition(
            widget.book.abbrev,
            widget.chapterNumber,
          );
      _loadHighlights();
    });
  }

  Future<void> _loadHighlights() async {
    final repository = ref.read(readingAnnotationRepositoryProvider);
    final highlights = await repository.listHighlights(_documentId);
    if (mounted) setState(() => _highlights = highlights);
  }

  Future<void> _saveHighlight({
    required int verseNumber,
    required int startOffset,
    required int endOffset,
  }) async {
    final highlight = ReadingHighlight(
      id: const Uuid().v4(),
      documentId: _documentId,
      blockId: '$verseNumber',
      startOffset: startOffset,
      endOffset: endOffset,
      colorKey: 'default',
      createdAt: DateTime.now(),
    );
    await ref.read(readingAnnotationRepositoryProvider).saveHighlight(highlight);
    await _loadHighlights();
  }

  Future<void> _deleteHighlight(String highlightId) async {
    await ref
        .read(readingAnnotationRepositoryProvider)
        .deleteHighlight(highlightId);
    await _loadHighlights();
  }

  void _shareVerseText({
    required BibleVerse verse,
    required String selectedText,
  }) {
    final reference =
        '${widget.book.name} ${widget.chapterNumber},${verse.number}';
    final formatted = '«$selectedText»\n\n— $reference';
    ref.read(nativeShareServiceProvider).shareText(formatted);
  }

  List<ReadingHighlight> _highlightsForVerse(int verseNumber) {
    return _highlights
        .where((h) => h.blockId == '$verseNumber')
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(
      bibleChapterProvider(
        BibleChapterRef(
          bookAbbrev: widget.book.abbrev,
          chapterNumber: widget.chapterNumber,
        ),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('${widget.book.name} ${widget.chapterNumber}'),
      ),
      child: SafeArea(
        child: chapterAsync.when(
          data: (verses) {
            if (verses.isEmpty) {
              return Center(
                child: Text(
                  'Capítulo vazio',
                  style: context.textStyles.secondary,
                ),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.xl + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: verses.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: IaculaSpacing.md),
              itemBuilder: (context, index) {
                final verse = verses[index];
                final verseHighlights = _highlightsForVerse(verse.number);
                return _BibleVerseBlock(
                  verse: verse,
                  highlights: verseHighlights,
                  onHighlight: ({
                    required int startOffset,
                    required int endOffset,
                    required ReadingHighlight? existingHighlight,
                  }) {
                    HapticFeedback.lightImpact();
                    if (existingHighlight != null) {
                      _deleteHighlight(existingHighlight.id);
                    } else {
                      _saveHighlight(
                        verseNumber: verse.number,
                        startOffset: startOffset,
                        endOffset: endOffset,
                      );
                    }
                  },
                  onShare: ({required String selectedText}) {
                    HapticFeedback.lightImpact();
                    _shareVerseText(
                      verse: verse,
                      selectedText: selectedText,
                    );
                  },
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(IaculaSpacing.md),
            child: IaculaShimmerList(itemCount: 10),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Não foi possível carregar o capítulo',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BibleVerseBlock extends StatelessWidget {
  const _BibleVerseBlock({
    required this.verse,
    required this.highlights,
    required this.onHighlight,
    required this.onShare,
  });

  final BibleVerse verse;
  final List<ReadingHighlight> highlights;
  final void Function({
    required int startOffset,
    required int endOffset,
    required ReadingHighlight? existingHighlight,
  }) onHighlight;
  final void Function({required String selectedText}) onShare;

  ReadingHighlight? _findMatchingHighlight(int start, int end) {
    for (final highlight in highlights) {
      if (highlight.startOffset == start && highlight.endOffset == end) {
        return highlight;
      }
    }
    return null;
  }

  TextSpan _buildHighlightedSpan(TextStyle style) {
    final text = verse.text;
    final validHighlights = highlights
        .where(
          (h) =>
              h.startOffset >= 0 &&
              h.endOffset <= text.length &&
              h.startOffset < h.endOffset,
        )
        .toList(growable: false)
      ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

    if (validHighlights.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final children = <TextSpan>[];
    var cursor = 0;

    for (final highlight in validHighlights) {
      if (highlight.startOffset < cursor) continue;
      if (highlight.startOffset > cursor) {
        children.add(TextSpan(text: text.substring(cursor, highlight.startOffset)));
      }
      children.add(
        TextSpan(
          text: text.substring(highlight.startOffset, highlight.endOffset),
          style: style.copyWith(
            backgroundColor: const Color(0x66FFD54F),
          ),
        ),
      );
      cursor = highlight.endOffset;
    }

    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }

    return TextSpan(style: style, children: children);
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState state) {
    final selection = state.textEditingValue.selection;
    final text = verse.text;
    final buttonItems = <ContextMenuButtonItem>[
      ...state.contextMenuButtonItems,
    ];

    final isValidSelection =
        !selection.isCollapsed &&
        selection.isValid &&
        selection.start >= 0 &&
        selection.end <= text.length &&
        selection.start < selection.end;

    if (isValidSelection) {
      final selectedText = text.substring(selection.start, selection.end);
      final existingHighlight =
          _findMatchingHighlight(selection.start, selection.end);

      buttonItems.insert(
        0,
        ContextMenuButtonItem(
          label: existingHighlight == null ? 'Destacar' : 'Remover destaque',
          onPressed: () {
            onHighlight(
              startOffset: selection.start,
              endOffset: selection.end,
              existingHighlight: existingHighlight,
            );
            state.hideToolbar();
          },
        ),
      );

      buttonItems.insert(
        1,
        ContextMenuButtonItem(
          label: 'Compartilhar',
          onPressed: () {
            onShare(selectedText: selectedText);
            state.hideToolbar();
          },
        ),
      );
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.textStyles.readingBody;
    final verseNumberStyle = context.textStyles.secondary.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: context.colors.primaryButton,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0, top: 5.0),
          child: Text('${verse.number}', style: verseNumberStyle),
        ),
        Expanded(
          child: SelectableText.rich(
            _buildHighlightedSpan(bodyStyle),
            contextMenuBuilder: _buildContextMenu,
          ),
        ),
      ],
    );
  }
}
