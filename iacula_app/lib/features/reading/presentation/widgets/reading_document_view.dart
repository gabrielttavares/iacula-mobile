import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/entities/reading_bookmark.dart';
import '../../domain/entities/reading_document_ref.dart';
import '../../domain/entities/reading_highlight.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/entities/reading_text_block.dart';
import 'annotatable_text_block.dart';

typedef ReadingTextStyleBuilder =
    TextStyle Function(
      BuildContext context,
      ReadingTextBlock block,
      double fontSize,
    );

class ReadingDocumentView extends ConsumerStatefulWidget {
  const ReadingDocumentView({
    super.key,
    required this.document,
    required this.fontSize,
    required this.styleBuilder,
    required this.onDecreaseFont,
    required this.onIncreaseFont,
    this.headerChildren = const <Widget>[],
    this.onOpenOriginal,
  });

  final ReadingDocumentRef document;
  final double fontSize;
  final ReadingTextStyleBuilder styleBuilder;
  final VoidCallback onDecreaseFont;
  final VoidCallback onIncreaseFont;
  final List<Widget> headerChildren;
  final VoidCallback? onOpenOriginal;

  @override
  ConsumerState<ReadingDocumentView> createState() => _ReadingDocumentViewState();
}

class _ReadingDocumentViewState extends ConsumerState<ReadingDocumentView> {
  static const _uuid = Uuid();

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _blockKeys = {};

  Map<String, List<ReadingHighlight>> _highlightsByBlock =
      <String, List<ReadingHighlight>>{};
  ReadingBookmark? _bookmark;
  String? _restoredDocumentId;
  String? _lastSavedProgressBlockId;

  @override
  void initState() {
    super.initState();
    _primeBlockKeys();
    unawaited(_loadAnnotations());
  }

  @override
  void didUpdateWidget(covariant ReadingDocumentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      _highlightsByBlock = <String, List<ReadingHighlight>>{};
      _bookmark = null;
      _lastSavedProgressBlockId = null;
      _primeBlockKeys();
      unawaited(_loadAnnotations());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification) {
              unawaited(_saveProgressForVisibleBlock());
            }
            return false;
          },
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              IaculaSpacing.lg,
              IaculaSpacing.lg,
              IaculaSpacing.lg,
              bottomInset + 96,
            ),
            children: [
              ...widget.headerChildren,
              for (final block in widget.document.blocks)
                Padding(
                  key: _blockKeys[block.id],
                  padding: EdgeInsets.only(bottom: _bottomSpacingFor(block)),
                  child: AnnotatableTextBlock(
                    text: block.text,
                    style: widget.styleBuilder(
                      context,
                      block,
                      widget.fontSize,
                    ),
                    highlights:
                        _highlightsByBlock[block.id] ?? const <ReadingHighlight>[],
                    onHighlightSelected: ({
                      required startOffset,
                      required endOffset,
                      required selectedText,
                      required existingHighlight,
                    }) {
                      if (existingHighlight != null) {
                        unawaited(_deleteHighlight(existingHighlight));
                        return;
                      }
                      unawaited(
                        _saveHighlight(
                          blockId: block.id,
                          startOffset: startOffset,
                          endOffset: endOffset,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          left: IaculaSpacing.md,
          right: IaculaSpacing.md,
          bottom: bottomInset + IaculaSpacing.md,
          child: _ReaderControls(
            canOpenOriginal: widget.onOpenOriginal != null,
            canGoToBookmark: _bookmark != null,
            onDecreaseFont: widget.onDecreaseFont,
            onIncreaseFont: widget.onIncreaseFont,
            onOpenOriginal: widget.onOpenOriginal,
            onSaveBookmark: _saveBookmark,
            onGoToBookmark: _bookmark == null
                ? null
                : () => _scrollToBlock(_bookmark!.blockId),
          ),
        ),
      ],
    );
  }

  double _bottomSpacingFor(ReadingTextBlock block) {
    return switch (block.type) {
      ReadingTextBlockType.title => IaculaSpacing.lg,
      ReadingTextBlockType.heading => 12,
      ReadingTextBlockType.summary => IaculaSpacing.lg,
      ReadingTextBlockType.paragraph => 14,
    };
  }

  Future<void> _loadAnnotations() async {
    final repository = ref.read(readingAnnotationRepositoryProvider);
    final highlights = await repository.listHighlights(widget.document.id);
    final bookmark = await repository.getBookmark(widget.document.id);
    final progress = await repository.getProgress(widget.document.id);
    if (!mounted) return;

    setState(() {
      _highlightsByBlock = _groupHighlights(highlights);
      _bookmark = bookmark;
    });

    if (_restoredDocumentId != widget.document.id) {
      _restoredDocumentId = widget.document.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetId = progress?.blockId;
        if (targetId != null) {
          unawaited(_scrollToBlock(targetId));
        }
      });
    }
  }

  Map<String, List<ReadingHighlight>> _groupHighlights(
    List<ReadingHighlight> highlights,
  ) {
    final validByBlock = <String, List<ReadingHighlight>>{};
    for (final highlight in highlights) {
      final block = widget.document.blocks
          .where((entry) => entry.id == highlight.blockId)
          .firstOrNull;
      if (block == null) continue;
      if (highlight.startOffset < 0 ||
          highlight.endOffset > block.text.length ||
          highlight.startOffset >= highlight.endOffset) {
        continue;
      }
      validByBlock.putIfAbsent(highlight.blockId, () => <ReadingHighlight>[]).add(
        highlight,
      );
    }
    return validByBlock;
  }

  void _primeBlockKeys() {
    _blockKeys
      ..clear()
      ..addEntries(
        widget.document.blocks.map((block) => MapEntry(block.id, GlobalKey())),
      );
  }

  Future<void> _saveHighlight({
    required String blockId,
    required int startOffset,
    required int endOffset,
  }) async {
    final repository = ref.read(readingAnnotationRepositoryProvider);
    final highlight = ReadingHighlight(
      id: _uuid.v4(),
      documentId: widget.document.id,
      blockId: blockId,
      startOffset: startOffset,
      endOffset: endOffset,
      colorKey: 'default',
      createdAt: DateTime.now().toUtc(),
    );
    await repository.saveHighlight(highlight);
    if (!mounted) return;
    setState(() {
      _highlightsByBlock
          .putIfAbsent(blockId, () => <ReadingHighlight>[])
          .add(highlight);
    });
  }

  Future<void> _deleteHighlight(ReadingHighlight highlight) async {
    await ref
        .read(readingAnnotationRepositoryProvider)
        .deleteHighlight(highlight.id);
    if (!mounted) return;
    setState(() {
      final updated = List<ReadingHighlight>.from(
        _highlightsByBlock[highlight.blockId] ?? const <ReadingHighlight>[],
      )..removeWhere((entry) => entry.id == highlight.id);
      if (updated.isEmpty) {
        _highlightsByBlock.remove(highlight.blockId);
      } else {
        _highlightsByBlock[highlight.blockId] = updated;
      }
    });
  }

  Future<void> _saveBookmark() async {
    final blockId = _findVisibleBlockId() ?? widget.document.blocks.firstOrNull?.id;
    if (blockId == null) return;
    final block = widget.document.blocks.firstWhere((entry) => entry.id == blockId);
    final bookmark = ReadingBookmark(
      documentId: widget.document.id,
      blockId: blockId,
      startOffset: 0,
      label: _truncateLabel(block.text),
      updatedAt: DateTime.now().toUtc(),
    );
    await ref.read(readingAnnotationRepositoryProvider).saveBookmark(bookmark);
    if (!mounted) return;
    setState(() {
      _bookmark = bookmark;
    });
  }

  Future<void> _saveProgressForVisibleBlock() async {
    final blockId = _findVisibleBlockId();
    if (blockId == null || blockId == _lastSavedProgressBlockId) return;
    _lastSavedProgressBlockId = blockId;
    await ref.read(readingAnnotationRepositoryProvider).saveProgress(
      ReadingProgress(
        documentId: widget.document.id,
        blockId: blockId,
        startOffset: 0,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  String? _findVisibleBlockId() {
    if (widget.document.blocks.isEmpty) return null;

    const targetOffset = 120.0;
    String? bestBlockId;
    var bestDistance = double.infinity;

    for (final block in widget.document.blocks) {
      final context = _blockKeys[block.id]?.currentContext;
      final box = context?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;

      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      if (bottom < 0) continue;

      final distance = (top - targetOffset).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestBlockId = block.id;
      }
    }

    return bestBlockId ?? widget.document.blocks.first.id;
  }

  Future<void> _scrollToBlock(String blockId) async {
    final context = _blockKeys[blockId]?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      alignment: 0.1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _truncateLabel(String text) {
    const maxLength = 28;
    final normalized = text.trim();
    if (normalized.length <= maxLength) return normalized;
    return '${normalized.substring(0, maxLength)}...';
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({
    required this.canOpenOriginal,
    required this.canGoToBookmark,
    required this.onDecreaseFont,
    required this.onIncreaseFont,
    required this.onOpenOriginal,
    required this.onSaveBookmark,
    required this.onGoToBookmark,
  });

  final bool canOpenOriginal;
  final bool canGoToBookmark;
  final VoidCallback onDecreaseFont;
  final VoidCallback onIncreaseFont;
  final VoidCallback? onOpenOriginal;
  final VoidCallback onSaveBookmark;
  final VoidCallback? onGoToBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IaculaSpacing.sm,
        vertical: IaculaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.card.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.systemGray6.withValues(alpha: 0.7),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(label: 'A-', onPressed: onDecreaseFont),
            const SizedBox(width: 6),
            _ControlButton(label: 'A+', onPressed: onIncreaseFont),
            const SizedBox(width: 6),
            _ControlButton(label: 'Marcar', onPressed: onSaveBookmark),
            if (canGoToBookmark) ...[
              const SizedBox(width: 6),
              _ControlButton(
                label: 'Ir ao marcador',
                onPressed: onGoToBookmark,
              ),
            ],
            if (canOpenOriginal) ...[
              const SizedBox(width: 6),
              _ControlButton(label: 'Abrir original', onPressed: onOpenOriginal),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.primaryButton,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
