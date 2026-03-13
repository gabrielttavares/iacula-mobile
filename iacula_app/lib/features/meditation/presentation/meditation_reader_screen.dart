import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/meditation_item.dart';

class MeditationReaderScreen extends ConsumerStatefulWidget {
  const MeditationReaderScreen({super.key, required this.item});

  final MeditationItem item;

  @override
  ConsumerState<MeditationReaderScreen> createState() =>
      _MeditationReaderScreenState();
}

class _MeditationReaderScreenState
    extends ConsumerState<MeditationReaderScreen> {
  late Future<MeditationTextContent?> _readerFuture;
  double _fontSize = 18;

  @override
  void initState() {
    super.initState();
    _readerFuture = ref
        .read(remoteMeditationReaderServiceProvider)
        .load(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.item.title),
        backgroundColor: context.colors.background.withValues(alpha: 0.96),
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<MeditationTextContent?>(
          future: _readerFuture,
          builder: (context, snapshot) {
            final content = snapshot.data ?? widget.item.textContent;

            if (snapshot.connectionState == ConnectionState.waiting &&
                content == null) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 16),
              );
            }

            if (content == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(IaculaSpacing.lg),
                  child: Text(
                    'Este texto não está disponível no momento.',
                    textAlign: TextAlign.center,
                    style: context.textStyles.secondary,
                  ),
                ),
              );
            }

            return Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    IaculaSpacing.lg,
                    IaculaSpacing.lg,
                    IaculaSpacing.lg,
                    bottomInset + 96,
                  ),
                  children: [
                    Text(
                      widget.item.title,
                      style: TextStyle(
                        fontSize: _fontSize + 10,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.item.summary.isNotEmpty) ...[
                      Text(
                        widget.item.summary,
                        style: TextStyle(
                          fontSize: _fontSize - 1,
                          height: 1.5,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.lg),
                    ],
                    _ReaderContent(content: content, fontSize: _fontSize),
                  ],
                ),
                Positioned(
                  left: IaculaSpacing.md,
                  right: IaculaSpacing.md,
                  bottom: bottomInset + IaculaSpacing.md,
                  child: _ReaderControls(
                    canOpenOriginal: widget.item.sourceUrl != null,
                    onDecreaseFont: () {
                      setState(() {
                        _fontSize = (_fontSize - 1).clamp(14, 24).toDouble();
                      });
                    },
                    onIncreaseFont: () {
                      setState(() {
                        _fontSize = (_fontSize + 1).clamp(14, 24).toDouble();
                      });
                    },
                    onOpenOriginal: widget.item.sourceUrl == null
                        ? null
                        : () => _openUrl(context, widget.item.sourceUrl!),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      await IaculaModal.showOpenLinkAlert(context);
    }
  }
}

class _ReaderContent extends StatelessWidget {
  const _ReaderContent({required this.content, required this.fontSize});

  final MeditationTextContent content;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final sections = content.sections ?? const <MeditationTextSection>[];
    if (sections.isEmpty) {
      return _ReaderParagraph(text: content.body, fontSize: fontSize);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          Text(
            section.heading,
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _ReaderParagraph(text: section.body, fontSize: fontSize),
          const SizedBox(height: IaculaSpacing.lg),
        ],
      ],
    );
  }
}

class _ReaderParagraph extends StatelessWidget {
  const _ReaderParagraph({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split(RegExp(r'\n{2,}'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraph in paragraphs) ...[
          Text(
            paragraph,
            style: context.textStyles.readingBody.copyWith(fontSize: fontSize),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({
    required this.canOpenOriginal,
    required this.onDecreaseFont,
    required this.onIncreaseFont,
    required this.onOpenOriginal,
  });

  final bool canOpenOriginal;
  final VoidCallback onDecreaseFont;
  final VoidCallback onIncreaseFont;
  final VoidCallback? onOpenOriginal;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(label: 'A-', onPressed: onDecreaseFont),
          const SizedBox(width: 6),
          _ControlButton(label: 'A+', onPressed: onIncreaseFont),
          if (canOpenOriginal) ...[
            const SizedBox(width: 6),
            _ControlButton(label: 'Abrir original', onPressed: onOpenOriginal),
          ],
        ],
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
      borderRadius: BorderRadius.circular(18),
      color: context.colors.secondaryButton,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
