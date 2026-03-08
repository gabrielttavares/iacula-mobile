import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/meditation_item.dart';
import 'widgets/meditation_web_content.dart';

class MeditationDetailScreen extends StatelessWidget {
  const MeditationDetailScreen({super.key, required this.item});

  final MeditationItem item;

  String? get _mediaUrl => switch (item.type) {
    MeditationType.text => null,
    MeditationType.video ||
    MeditationType.audio => item.mediaUrl ?? item.sourceUrl,
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(item.sourceName),
        backgroundColor: context.colors.background,
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(item: item),
              const SizedBox(height: IaculaSpacing.md),
              _HelperBanner(text: _helperText),
              const SizedBox(height: IaculaSpacing.md),
              Expanded(
                child: _ContentArea(item: item, mediaUrl: _mediaUrl),
              ),
              if (item.sourceUrl != null) ...[
                const SizedBox(height: IaculaSpacing.md),
                IaculaSecondaryPillButton(
                  label: 'Abrir fonte original',
                  onPressed: () => _openUrl(context, item.sourceUrl!),
                ),
              ],
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _helperText => switch (item.type) {
    MeditationType.video => 'Assista sem sair do app.',
    MeditationType.audio =>
      'Ouça sem sair do app, inclusive com o app em segundo plano quando o provedor permitir.',
    MeditationType.text =>
      'Leia em modo foco, com texto nativo e tipografia confortável dentro do app.',
  };

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Erro'),
          content: const Text('Não foi possível abrir o link.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeIcon(type: item.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: context.textStyles.sectionTitle),
                    const SizedBox(height: 4),
                    Text(item.sourceName, style: context.textStyles.secondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (item.durationLabel != null)
                _DetailBadge(
                  icon: CupertinoIcons.clock,
                  text: item.durationLabel!,
                ),
              if (item.availability.kind == MeditationAvailabilityKind.daily)
                const _DetailBadge(
                  icon: CupertinoIcons.calendar,
                  text: 'Conteúdo diário',
                ),
              for (final tag in item.categoryTags) _DetailBadge(text: tag),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelperBanner extends StatelessWidget {
  const _HelperBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IaculaSpacing.md,
        vertical: IaculaSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.systemGray6,
        borderRadius: BorderRadius.circular(IaculaRadius.card),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.item, required this.mediaUrl});

  final MeditationItem item;
  final String? mediaUrl;

  @override
  Widget build(BuildContext context) {
    return switch (item.type) {
      MeditationType.text => _TextReaderContent(item: item),
      MeditationType.video ||
      MeditationType.audio => _MediaContent(item: item, mediaUrl: mediaUrl),
    };
  }
}

class _TextReaderContent extends ConsumerStatefulWidget {
  const _TextReaderContent({required this.item});

  final MeditationItem item;

  @override
  ConsumerState<_TextReaderContent> createState() => _TextReaderContentState();
}

class _TextReaderContentState extends ConsumerState<_TextReaderContent> {
  late Future<MeditationTextContent?> _readerFuture;
  int _textSizePreset = 1;

  static const _fontSizeByPreset = {0: 16.0, 1: 18.0, 2: 20.0};

  @override
  void initState() {
    super.initState();
    _readerFuture = ref
        .read(remoteMeditationReaderServiceProvider)
        .load(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MeditationTextContent?>(
      future: _readerFuture,
      builder: (context, snapshot) {
        final resolvedContent = snapshot.data ?? widget.item.textContent;
        if (snapshot.connectionState == ConnectionState.waiting &&
            resolvedContent == null) {
          return const Center(child: CupertinoActivityIndicator(radius: 16));
        }

        if (resolvedContent == null) {
          return const _UnavailableContent(
            message: 'Este texto não está disponível no momento.',
          );
        }

        final fontSize = _fontSizeByPreset[_textSizePreset]!;
        final isRemote = snapshot.data != null;

        return Column(
          children: [
            _ReaderToolbar(
              isRemote: isRemote,
              selectedPreset: _textSizePreset,
              onPresetChanged: (value) {
                if (value == null) return;
                setState(() => _textSizePreset = value);
              },
            ),
            const SizedBox(height: IaculaSpacing.md),
            Expanded(
              child: _ReaderBody(
                item: widget.item,
                content: resolvedContent,
                fontSize: fontSize,
                isRemote: isRemote,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({
    required this.isRemote,
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  final bool isRemote;
  final int selectedPreset;
  final ValueChanged<int?> onPresetChanged;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRemote ? 'Modo leitura' : 'Prévia editorial',
                  style: context.textStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  isRemote
                      ? 'Texto carregado e tratado dentro do app.'
                      : 'Versão simplificada enquanto a fonte completa não está disponível.',
                  style: context.textStyles.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: selectedPreset,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('A-'),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('A'),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('A+'),
              ),
            },
            onValueChanged: onPresetChanged,
          ),
        ],
      ),
    );
  }
}

class _ReaderBody extends StatelessWidget {
  const _ReaderBody({
    required this.item,
    required this.content,
    required this.fontSize,
    required this.isRemote,
  });

  final MeditationItem item;
  final MeditationTextContent content;
  final double fontSize;
  final bool isRemote;

  @override
  Widget build(BuildContext context) {
    final sections = content.sections ?? const <MeditationTextSection>[];
    final hasSections = sections.isNotEmpty;

    return IaculaSoftCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          IaculaSpacing.lg,
          IaculaSpacing.lg,
          IaculaSpacing.lg,
          IaculaSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: fontSize + 10,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.summary,
              style: TextStyle(
                fontSize: fontSize - 2,
                height: 1.55,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: IaculaSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReaderPill(
                  icon: CupertinoIcons.book,
                  text: isRemote ? 'Texto sincronizado' : 'Leitura compacta',
                ),
                _ReaderPill(
                  icon: CupertinoIcons.textformat_size,
                  text: 'Modo foco',
                ),
              ],
            ),
            const SizedBox(height: IaculaSpacing.lg),
            if (hasSections)
              for (final section in sections) ...[
                Text(
                  section.heading,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _ReaderParagraph(text: section.body, fontSize: fontSize),
                const SizedBox(height: IaculaSpacing.lg),
              ]
            else
              _ReaderParagraph(text: content.body, fontSize: fontSize),
          ],
        ),
      ),
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
            style: TextStyle(
              fontSize: fontSize,
              height: 1.75,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ReaderPill extends StatelessWidget {
  const _ReaderPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.systemGray6,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  const _MediaContent({required this.item, required this.mediaUrl});

  final MeditationItem item;
  final String? mediaUrl;

  @override
  Widget build(BuildContext context) {
    if (mediaUrl != null) {
      return MeditationWebContent(
        url: mediaUrl!,
        title: item.title,
        fallback: _MediaFallback(item: item),
      );
    }

    return _MediaFallback(item: item);
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MeditationType.video;

    return IaculaSoftCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo
                ? CupertinoIcons.play_circle_fill
                : CupertinoIcons.waveform_circle_fill,
            size: 64,
            color: context.colors.primaryButton,
          ),
          const SizedBox(height: 16),
          Text(
            item.summary,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableContent extends StatelessWidget {
  const _UnavailableContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.secondary,
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final MeditationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MeditationType.video => (
        CupertinoIcons.play_circle,
        context.colors.primaryButton,
      ),
      MeditationType.audio => (
        CupertinoIcons.waveform,
        const Color(0xFF34C759),
      ),
      MeditationType.text => (CupertinoIcons.doc_text, const Color(0xFFFF9500)),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.systemGray6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: context.colors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
