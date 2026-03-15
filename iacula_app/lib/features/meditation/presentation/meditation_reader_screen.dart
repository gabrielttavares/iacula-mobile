import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../reading/application/meditation_reading_document_mapper.dart';
import '../../reading/domain/entities/reading_document_ref.dart';
import '../../reading/domain/entities/reading_text_block.dart';
import '../../reading/presentation/widgets/reading_document_view.dart';
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

            return ReadingDocumentView(
              document: _buildDocument(content),
              fontSize: _fontSize,
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
              headerChildren: [
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
              ],
              styleBuilder: (context, block, fontSize) {
                return switch (block.type) {
                  ReadingTextBlockType.heading => TextStyle(
                    fontSize: fontSize + 4,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: context.colors.textPrimary,
                  ),
                  ReadingTextBlockType.summary => TextStyle(
                    fontSize: fontSize - 1,
                    height: 1.5,
                    color: context.colors.textSecondary,
                  ),
                  _ => context.textStyles.readingBody.copyWith(
                    fontSize: fontSize,
                  ),
                };
              },
            );
          },
        ),
      ),
    );
  }

  ReadingDocumentRef _buildDocument(MeditationTextContent content) {
    return mapMeditationToReadingDocument(
      MeditationItem(
        id: widget.item.id,
        type: widget.item.type,
        title: widget.item.title,
        summary: widget.item.summary,
        categoryTags: widget.item.categoryTags,
        sourceName: widget.item.sourceName,
        availability: widget.item.availability,
        provenance: widget.item.provenance,
        durationSec: widget.item.durationSec,
        readingTimeSec: widget.item.readingTimeSec,
        sourceUrl: widget.item.sourceUrl,
        mediaUrl: widget.item.mediaUrl,
        imageUrl: widget.item.imageUrl,
        dateRef: widget.item.dateRef,
        textContent: content,
        premiumTier: widget.item.premiumTier,
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
