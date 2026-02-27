import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/meditation_item.dart';

class MeditationDetailScreen extends StatelessWidget {
  const MeditationDetailScreen({super.key, required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(item.sourceName),
        backgroundColor: IaculaColors.background,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(item: item),
              const SizedBox(height: IaculaSpacing.lg),
              _ContentArea(item: item),
              const SizedBox(height: IaculaSpacing.lg),
              _ActionButtons(item: item),
            ],
          ),
        ),
      ),
    );
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
                    Text(item.title, style: IaculaText.sectionTitle),
                    const SizedBox(height: 4),
                    Text(item.sourceName, style: IaculaText.secondary),
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
              for (final tag in item.categoryTags)
                _DetailBadge(text: tag),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.type) {
      MeditationType.text => _TextContent(item: item),
      MeditationType.video => _MediaContent(item: item),
      MeditationType.audio => _MediaContent(item: item),
    };
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    final content = item.textContent;
    if (content == null) return const SizedBox.shrink();

    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.sections != null)
            for (final section in content.sections!) ...[
              Text(
                section.heading,
                style: IaculaText.cardTitle,
              ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: IaculaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ]
          else
            Text(
              content.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: IaculaColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  const _MediaContent({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == MeditationType.video;

    return IaculaSoftCard(
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isVideo
                    ? CupertinoIcons.play_circle_fill
                    : CupertinoIcons.waveform_circle_fill,
                size: 64,
                color: IaculaColors.primaryButton,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.summary,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: IaculaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.item});

  final MeditationItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (item.sourceUrl != null) ...[
          IaculaPrimaryPillButton(
            label: _primaryLabel,
            onPressed: () => _openUrl(context, item.sourceUrl!),
          ),
          const SizedBox(height: 12),
          IaculaSecondaryPillButton(
            label: 'Abrir fonte original',
            onPressed: () => _openUrl(context, item.sourceUrl!),
          ),
        ],
      ],
    );
  }

  String get _primaryLabel => switch (item.type) {
    MeditationType.video => 'Assistir',
    MeditationType.audio => 'Ouvir',
    MeditationType.text => 'Ler na fonte',
  };

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri) && context.mounted) {
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

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final MeditationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MeditationType.video => (CupertinoIcons.play_circle, IaculaColors.primaryButton),
      MeditationType.audio => (CupertinoIcons.waveform, const Color(0xFF34C759)),
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
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: IaculaColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: IaculaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
