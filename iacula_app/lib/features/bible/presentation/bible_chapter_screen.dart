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
import '../domain/bible_chapter_navigation.dart';
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
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _navigateToChapter(BibleChapterLocation location) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) => BibleChapterScreen(
          book: location.book,
          chapterNumber: location.chapterNumber,
        ),
      ),
    );
  }

  ({BibleChapterLocation? previous, BibleChapterLocation? next})
      _chapterNavigation(List<BibleBook> books) {
    return (
      previous: getPreviousChapterLocation(
        books: books,
        currentBook: widget.book,
        currentChapter: widget.chapterNumber,
      ),
      next: getNextChapterLocation(
        books: books,
        currentBook: widget.book,
        currentChapter: widget.chapterNumber,
      ),
    );
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
    final booksAsync = ref.watch(bibleBooksProvider);
    final navigation = booksAsync.maybeWhen(
      data: _chapterNavigation,
      orElse: () => (previous: null, next: null),
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('${widget.book.name} ${widget.chapterNumber}'),
        trailing: _ChapterNavBarActions(
          previousLocation: navigation.previous,
          nextLocation: navigation.next,
          onNavigate: _navigateToChapter,
        ),
      ),
      child: SafeArea(
        child: _ChapterEdgeSwipeDetector(
          previousLocation: navigation.previous,
          nextLocation: navigation.next,
          onNavigate: _navigateToChapter,
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
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  IaculaSpacing.md,
                  IaculaSpacing.md,
                  IaculaSpacing.md,
                  IaculaSpacing.xl + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: verses.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: IaculaSpacing.md),
                itemBuilder: (context, index) {
                  if (index == verses.length) {
                    return _ChapterNavigationFooter(
                      previousLocation: navigation.previous,
                      nextLocation: navigation.next,
                      onNavigate: _navigateToChapter,
                    );
                  }

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
      ),
    );
  }
}

class _ChapterNavBarActions extends StatelessWidget {
  const _ChapterNavBarActions({
    required this.previousLocation,
    required this.nextLocation,
    required this.onNavigate,
  });

  final BibleChapterLocation? previousLocation;
  final BibleChapterLocation? nextLocation;
  final ValueChanged<BibleChapterLocation> onNavigate;

  @override
  Widget build(BuildContext context) {
    if (previousLocation == null && nextLocation == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChapterNavIconButton(
          icon: CupertinoIcons.chevron_left,
          enabled: previousLocation != null,
          onPressed: previousLocation == null
              ? null
              : () => onNavigate(previousLocation!),
        ),
        _ChapterNavIconButton(
          icon: CupertinoIcons.chevron_right,
          enabled: nextLocation != null,
          onPressed:
              nextLocation == null ? null : () => onNavigate(nextLocation!),
        ),
      ],
    );
  }
}

class _ChapterNavIconButton extends StatelessWidget {
  const _ChapterNavIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      onPressed: enabled ? onPressed : null,
      child: Icon(
        icon,
        size: 22,
        color: enabled
            ? context.colors.primaryButton
            : context.colors.textSecondary.withValues(alpha: 0.35),
      ),
    );
  }
}

class _ChapterNavigationFooter extends StatelessWidget {
  const _ChapterNavigationFooter({
    required this.previousLocation,
    required this.nextLocation,
    required this.onNavigate,
  });

  final BibleChapterLocation? previousLocation;
  final BibleChapterLocation? nextLocation;
  final ValueChanged<BibleChapterLocation> onNavigate;

  @override
  Widget build(BuildContext context) {
    if (previousLocation == null && nextLocation == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: IaculaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 1,
            color: context.colors.separator,
          ),
          const SizedBox(height: IaculaSpacing.lg),
          if (nextLocation != null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: IaculaSpacing.md),
              color: context.colors.primaryButton,
              borderRadius: BorderRadius.circular(24),
              onPressed: () => onNavigate(nextLocation!),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Próximo capítulo',
                      textAlign: TextAlign.center,
                      style: context.textStyles.cardTitle.copyWith(
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  Text(
                    nextLocation!.label,
                    style: context.textStyles.secondary.copyWith(
                      color: CupertinoColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: IaculaSpacing.xs),
                  const Icon(
                    CupertinoIcons.arrow_right,
                    color: CupertinoColors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          if (previousLocation != null) ...[
            if (nextLocation != null) const SizedBox(height: IaculaSpacing.sm),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: IaculaSpacing.md),
              color: context.colors.secondaryButton,
              borderRadius: BorderRadius.circular(24),
              onPressed: () => onNavigate(previousLocation!),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_left,
                    color: context.colors.textPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: IaculaSpacing.xs),
                  Text(
                    previousLocation!.label,
                    style: context.textStyles.secondary.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Capítulo anterior',
                      textAlign: TextAlign.center,
                      style: context.textStyles.cardTitle.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterEdgeSwipeDetector extends StatefulWidget {
  const _ChapterEdgeSwipeDetector({
    required this.previousLocation,
    required this.nextLocation,
    required this.onNavigate,
    required this.child,
  });

  final BibleChapterLocation? previousLocation;
  final BibleChapterLocation? nextLocation;
  final ValueChanged<BibleChapterLocation> onNavigate;
  final Widget child;

  @override
  State<_ChapterEdgeSwipeDetector> createState() =>
      _ChapterEdgeSwipeDetectorState();
}

class _ChapterEdgeSwipeDetectorState extends State<_ChapterEdgeSwipeDetector> {
  static const _edgeWidthFraction = 0.18;
  static const _swipeVelocityThreshold = 350.0;

  double? _dragStartX;
  bool _startedInEdgeZone = false;

  bool _isInEdgeZone(double localX, double width) {
    final edgeWidth = width * _edgeWidthFraction;
    return localX <= edgeWidth || localX >= width - edgeWidth;
  }

  void _handleDragStart(DragStartDetails details) {
    final width = context.size?.width ?? MediaQuery.sizeOf(context).width;
    _dragStartX = details.localPosition.dx;
    _startedInEdgeZone = _isInEdgeZone(details.localPosition.dx, width);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_startedInEdgeZone || _dragStartX == null) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) return;

    if (velocity < 0 && widget.nextLocation != null) {
      widget.onNavigate(widget.nextLocation!);
    } else if (velocity > 0 && widget.previousLocation != null) {
      widget.onNavigate(widget.previousLocation!);
    }

    _dragStartX = null;
    _startedInEdgeZone = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragEnd: _handleDragEnd,
      child: widget.child,
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
