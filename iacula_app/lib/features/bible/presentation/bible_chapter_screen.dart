import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AdaptiveTextSelectionToolbar,
        ContextMenuButtonItem,
        EditableTextState,
        SelectableText,
        TextSpan;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/rendering.dart' show RenderEditable;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/presentation/widgets/font_size_controls.dart';
import '../../reading/domain/entities/reading_highlight.dart';
import '../../reading/presentation/widgets/annotatable_text_block.dart';
import '../domain/bible_chapter_navigation.dart';
import '../domain/bible_citation.dart';
import '../domain/bible_chapter_selection.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/bible_chapter_ref.dart';
import '../domain/entities/bible_verse.dart';
import 'bible_citation_sheet.dart';

class BibleChapterScreen extends ConsumerStatefulWidget {
  const BibleChapterScreen({
    super.key,
    required this.book,
    required this.chapterNumber,
    this.focus,
  });

  final BibleBook book;
  final int chapterNumber;

  /// Verses to tint and scroll to, when opened from a citation. Opening with a
  /// focus does not move the user's saved Bible reading position.
  final BibleReference? focus;

  @override
  ConsumerState<BibleChapterScreen> createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends ConsumerState<BibleChapterScreen> {
  List<ReadingHighlight> _highlights = [];
  late final String _documentId;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();
  bool _scrolledToFocus = false;

  /// Cross-references inside the verses ("(Os. 10, 8)"), parsed once per
  /// loaded chapter, with their tap recognizers.
  List<BibleVerse>? _citationVerses;
  Map<int, List<VerseCitationLink>> _citationsByVerse = const {};

  Map<int, List<VerseCitationLink>> _citationsFor(List<BibleVerse> verses) {
    if (identical(verses, _citationVerses)) return _citationsByVerse;
    _disposeCitations();
    const parser = BibleCitationParser();
    _citationVerses = verses;
    _citationsByVerse = {
      for (final verse in verses)
        if (parser.parse(verse.text) case final found when found.isNotEmpty)
          verse.number: [
            for (final citation in found)
              VerseCitationLink(
                citation,
                TapGestureRecognizer()
                  ..onTap = () => showBibleCitationSheet(context, citation),
              ),
          ],
    };
    return _citationsByVerse;
  }

  void _disposeCitations() {
    for (final links in _citationsByVerse.values) {
      for (final link in links) {
        link.recognizer.dispose();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _documentId = 'bible:${widget.book.abbrev}:${widget.chapterNumber}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focus == null) {
        ref.read(biblePrefsProvider.notifier).savePosition(
              widget.book.abbrev,
              widget.chapterNumber,
            );
      }
      _loadHighlights();
    });
  }

  /// Scrolls so the first focused verse sits near the top of the screen. The
  /// chapter is a single selectable text, so the verse position comes from the
  /// text layout rather than from a widget per verse.
  void _scrollToFocusOnce(List<BibleVerse> verses) {
    final focus = widget.focus;
    if (focus == null || _scrolledToFocus) return;
    _scrolledToFocus = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final segment = buildVerseSegments(verses)
          .where((s) => focus.containsVerse(s.verseNumber))
          .firstOrNull;
      final root = _contentKey.currentContext?.findRenderObject();
      if (segment == null || root == null) return;

      RenderEditable? editable;
      void visit(RenderObject node) {
        if (editable != null) return;
        if (node is RenderEditable) {
          editable = node;
          return;
        }
        node.visitChildren(visit);
      }

      visit(root);
      final target = editable;
      final viewport = context.findRenderObject();
      if (target == null || viewport is! RenderBox) return;

      final caret = target.getLocalRectForCaret(
        TextPosition(offset: segment.textStartGlobal),
      );
      final dy = target.localToGlobal(caret.topLeft, ancestor: viewport).dy;
      final position = _scrollController.position;
      final offset = (_scrollController.offset + dy - 120).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _disposeCitations();
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
    if (mounted) {
      setState(() => _highlights = [..._highlights, highlight]);
    }
  }

  Future<void> _toggleHighlightsForSelection({
    required List<BibleVerseHighlightRange> ranges,
  }) async {
    if (ranges.isEmpty) return;

    final existingHighlights = ranges
        .map(
          (range) => findExactMatchingHighlight(
            _highlightsForVerse(range.verseNumber),
            startOffset: range.startOffset,
            endOffset: range.endOffset,
          ),
        )
        .toList(growable: false);

    final shouldRemove = existingHighlights.every((highlight) => highlight != null);
    if (shouldRemove) {
      for (final highlight in existingHighlights) {
        if (highlight != null) {
          await _deleteHighlight(highlight.id, reload: false);
        }
      }
      if (mounted) await _loadHighlights();
      return;
    }

    for (var index = 0; index < ranges.length; index++) {
      if (existingHighlights[index] != null) continue;
      final range = ranges[index];
      await _saveHighlight(
        verseNumber: range.verseNumber,
        startOffset: range.startOffset,
        endOffset: range.endOffset,
      );
    }
  }

  Future<void> _deleteHighlight(
    String highlightId, {
    bool reload = true,
  }) async {
    await ref
        .read(readingAnnotationRepositoryProvider)
        .deleteHighlight(highlightId);
    if (!reload) {
      if (mounted) {
        setState(
          () => _highlights =
              _highlights.where((highlight) => highlight.id != highlightId).toList(),
        );
      }
      return;
    }
    await _loadHighlights();
  }

  void _shareSelectedText({
    required String selectedText,
    required List<BibleVerseSegment> segments,
    required int globalStart,
    required int globalEnd,
  }) {
    final reference = formatBibleSelectionReference(
      bookName: widget.book.name,
      chapterNumber: widget.chapterNumber,
      segments: segments,
      globalStart: globalStart,
      globalEnd: globalEnd,
    );
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
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();
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
        child: FutureBuilder(
          future: settingsAsync,
          builder: (context, settingsSnapshot) {
            final fontSize = settingsSnapshot.data?.prayerFontSize ?? 15.0;

            return _ChapterEdgeSwipeDetector(
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
                  _scrollToFocusOnce(verses);
                  return ListView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      IaculaSpacing.md,
                      IaculaSpacing.md,
                      IaculaSpacing.md,
                      IaculaSpacing.xl + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: FontSizeControls(),
                      ),
                      const SizedBox(height: IaculaSpacing.sm),
                      _BibleChapterSelectableContent(
                        key: _contentKey,
                        verses: verses,
                        citations: _citationsFor(verses),
                        focus: widget.focus,
                        fontSize: fontSize,
                        highlights: _highlights,
                        onToggleHighlights: _toggleHighlightsForSelection,
                        onShareSelectedText: _shareSelectedText,
                      ),
                      const SizedBox(height: IaculaSpacing.md),
                      _ChapterNavigationFooter(
                        previousLocation: navigation.previous,
                        nextLocation: navigation.next,
                        onNavigate: _navigateToChapter,
                      ),
                    ],
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
            );
          },
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
              padding: const EdgeInsets.symmetric(
                horizontal: IaculaSpacing.md,
                vertical: IaculaSpacing.md,
              ),
              color: context.colors.primaryButton,
              borderRadius: BorderRadius.circular(24),
              onPressed: () => onNavigate(nextLocation!),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo capítulo',
                          style: context.textStyles.cardTitle.copyWith(
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextLocation!.label,
                          style: context.textStyles.secondary.copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.arrow_right,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          if (previousLocation != null) ...[
            if (nextLocation != null) const SizedBox(height: IaculaSpacing.sm),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: IaculaSpacing.md,
                vertical: IaculaSpacing.md,
              ),
              color: context.colors.secondaryButton,
              borderRadius: BorderRadius.circular(24),
              onPressed: () => onNavigate(previousLocation!),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_left,
                    color: context.colors.textPrimary,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Capítulo anterior',
                          style: context.textStyles.cardTitle.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          previousLocation!.label,
                          style: context.textStyles.secondary.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
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

class _BibleChapterSelectableContent extends StatelessWidget {
  const _BibleChapterSelectableContent({
    super.key,
    required this.verses,
    this.citations = const {},
    this.focus,
    required this.fontSize,
    required this.highlights,
    required this.onToggleHighlights,
    required this.onShareSelectedText,
  });

  final List<BibleVerse> verses;
  final Map<int, List<VerseCitationLink>> citations;
  final BibleReference? focus;
  final double fontSize;
  final List<ReadingHighlight> highlights;
  final Future<void> Function({
    required List<BibleVerseHighlightRange> ranges,
  }) onToggleHighlights;
  final void Function({
    required String selectedText,
    required List<BibleVerseSegment> segments,
    required int globalStart,
    required int globalEnd,
  }) onShareSelectedText;

  List<ReadingHighlight> _highlightsForVerse(int verseNumber) {
    return highlights
        .where((highlight) => highlight.blockId == '$verseNumber')
        .toList(growable: false);
  }

  /// Splits a verse at every highlight and cross-reference boundary, so a
  /// segment can be both highlighted and a tappable citation.
  TextSpan _buildVerseTextSpan({
    required String text,
    required List<ReadingHighlight> verseHighlights,
    required List<VerseCitationLink> links,
    required TextStyle bodyStyle,
    required TextStyle linkStyle,
  }) {
    final validHighlights = verseHighlights
        .where(
          (highlight) =>
              highlight.startOffset >= 0 &&
              highlight.endOffset <= text.length &&
              highlight.startOffset < highlight.endOffset,
        )
        .toList(growable: false);

    if (validHighlights.isEmpty && links.isEmpty) {
      return TextSpan(style: bodyStyle, text: text);
    }

    final cuts = <int>{0, text.length};
    for (final h in validHighlights) {
      cuts
        ..add(h.startOffset)
        ..add(h.endOffset);
    }
    for (final link in links) {
      cuts
        ..add(link.citation.start)
        ..add(link.citation.end);
    }
    final sorted = cuts.toList()..sort();

    final children = <TextSpan>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final from = sorted[i];
      final to = sorted[i + 1];
      if (from >= to) continue;
      final highlighted = validHighlights.any(
        (h) => h.startOffset <= from && h.endOffset >= to,
      );
      final link = links
          .where((l) => l.citation.start <= from && l.citation.end >= to)
          .firstOrNull;
      var style = link != null ? linkStyle : null;
      if (highlighted) {
        style = (style ?? bodyStyle).copyWith(
          backgroundColor: const Color(0x66FFD54F),
        );
      }
      children.add(
        TextSpan(
          text: text.substring(from, to),
          style: style,
          recognizer: link?.recognizer,
        ),
      );
    }

    return TextSpan(style: bodyStyle, children: children);
  }

  TextSpan _buildChapterSpan({
    required TextStyle bodyStyle,
    required TextStyle verseNumberStyle,
    required Color focusBackground,
    required TextStyle linkStyle,
  }) {
    final children = <InlineSpan>[];

    for (var index = 0; index < verses.length; index++) {
      final verse = verses[index];
      final numberPrefix = '${verse.number}  ';

      children
        ..add(TextSpan(text: numberPrefix, style: verseNumberStyle))
        ..add(
          _buildVerseTextSpan(
            text: verse.text,
            verseHighlights: _highlightsForVerse(verse.number),
            links: citations[verse.number] ?? const [],
            linkStyle: linkStyle,
            bodyStyle: focus?.containsVerse(verse.number) ?? false
                ? bodyStyle.copyWith(backgroundColor: focusBackground)
                : bodyStyle,
          ),
        );

      if (index < verses.length - 1) {
        children.add(const TextSpan(text: '\n\n'));
      }
    }

    return TextSpan(style: bodyStyle, children: children);
  }

  String _combinedPlainText() {
    final buffer = StringBuffer();
    for (var index = 0; index < verses.length; index++) {
      buffer
        ..write('${verses[index].number}  ')
        ..write(verses[index].text);
      if (index < verses.length - 1) {
        buffer.write('\n\n');
      }
    }
    return buffer.toString();
  }

  bool _selectionMatchesExistingHighlights({
    required List<BibleVerseHighlightRange> ranges,
  }) {
    if (ranges.isEmpty) return false;

    return ranges.every(
      (range) =>
          findExactMatchingHighlight(
            _highlightsForVerse(range.verseNumber),
            startOffset: range.startOffset,
            endOffset: range.endOffset,
          ) !=
          null,
    );
  }

  Widget _buildContextMenu(
    BuildContext context,
    EditableTextState state,
    List<BibleVerseSegment> segments,
    String combinedText,
  ) {
    final selection = state.textEditingValue.selection;
    final buttonItems = <ContextMenuButtonItem>[
      ...state.contextMenuButtonItems,
    ];

    final isValidSelection =
        !selection.isCollapsed &&
        selection.isValid &&
        selection.start >= 0 &&
        selection.end <= combinedText.length &&
        selection.start < selection.end;

    if (isValidSelection) {
      final selectedText =
          combinedText.substring(selection.start, selection.end);
      final highlightRanges = mapGlobalSelectionToVerseRanges(
        segments: segments,
        globalStart: selection.start,
        globalEnd: selection.end,
      );
      final hasExistingHighlights = _selectionMatchesExistingHighlights(
        ranges: highlightRanges,
      );

      buttonItems.insert(
        0,
        ContextMenuButtonItem(
          label: hasExistingHighlights ? 'Remover destaque' : 'Destacar',
          onPressed: () {
            HapticFeedback.lightImpact();
            onToggleHighlights(ranges: highlightRanges);
            state.hideToolbar();
          },
        ),
      );

      buttonItems.insert(
        1,
        ContextMenuButtonItem(
          label: 'Compartilhar',
          onPressed: () {
            HapticFeedback.lightImpact();
            onShareSelectedText(
              selectedText: selectedText,
              segments: segments,
              globalStart: selection.start,
              globalEnd: selection.end,
            );
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
    final bodyStyle = context.textStyles.readingBody.copyWith(fontSize: fontSize);
    final verseNumberStyle = context.textStyles.secondary.copyWith(
      fontSize: (fontSize - 4).clamp(10.0, 20.0),
      fontWeight: FontWeight.bold,
      color: context.colors.primaryButton,
    );
    final segments = buildVerseSegments(verses);
    final combinedText = _combinedPlainText();

    return SelectableText.rich(
      _buildChapterSpan(
        bodyStyle: bodyStyle,
        verseNumberStyle: verseNumberStyle,
        focusBackground: context.colors.primaryButton.withValues(alpha: 0.14),
        linkStyle: bodyStyle.copyWith(
          color: context.colors.primaryButton,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        ),
      ),
      contextMenuBuilder: (context, state) =>
          _buildContextMenu(context, state, segments, combinedText),
    );
  }
}

/// A cross-reference found in a verse and the recognizer that opens it.
final class VerseCitationLink {
  const VerseCitationLink(this.citation, this.recognizer);

  final BibleCitation citation;
  final TapGestureRecognizer recognizer;
}
